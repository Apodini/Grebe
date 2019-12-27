//
//  BidirectionalStreamingCallTests.swift
//
//
//  Created by Tim Mewe on 27.12.19.
//

import Combine
@testable import Grebe_Framework
import GRPC
import NIO
import XCTest

final class BidirectionalStreamingCallTests: BaseCallTest {
    var client: GClient<BidirectionalStreamingScenariosServiceClient>!

    override func setUp() {
        super.setUp()
        serverEventLoopGroup = try? makeTestServer(services: [BidirectionalStreamingTestService()])
        client = makeTestClient()
    }

    override func tearDown() {
        try? client.service.connection.close().wait()
        super.tearDown()
    }

    func testOk() {
        let promise = expectation(description: "Call completes successfully")

        let requests = repeatElement(EchoRequest.with { $0.message = "hello" }, count: 3)
        let requestStream = Publishers
            .Sequence<Repeated<EchoRequest>, Error>(sequence: requests)
            .eraseToAnyPublisher()

        let call = GBidirectionalStreamingCall(
            request: GRequestStream(requestStream),
            closure: client.service.ok
        )

        call.execute()
            .filter { $0.message == "hello" }
            .count()
            .sink(
                receiveCompletion: {
                    switch $0 {
                    case .failure(let status):
                        XCTFail("Unexpected status: " + status.localizedDescription)
                    case .finished:
                        promise.fulfill()
                } },
                receiveValue: { count in
                    XCTAssert(count == 3)
                }
            )
            .store(in: &cancellables)

        wait(for: [promise], timeout: 0.2)
    }

    func testFailedPrecondition() {
        let promise = expectation(description: "Call fails with failed precondition status")

        let requests = repeatElement(EchoRequest.with { $0.message = "hello" }, count: 3)
        let requestStream = Publishers
            .Sequence<Repeated<EchoRequest>, Error>(sequence: requests)
            .eraseToAnyPublisher()

        let call = GBidirectionalStreamingCall(
            request: GRequestStream(requestStream),
            closure: client.service.failedPrecondition
        )

        call.execute()
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let status):
                        if status.code == .failedPrecondition {
                            promise.fulfill()
                        } else {
                            XCTFail("Unexpected status: " + status.localizedDescription)
                        }
                    case .finished:
                        XCTFail("Call should not succeed")
                    }
                },
                receiveValue: { _ in
                    XCTFail("Call should not return a response")
                }
            )
            .store(in: &cancellables)

        wait(for: [promise], timeout: 0.2)
    }

    func testNoResponse() {
        let promise = expectation(description: "Call fails with deadline exceeded status")

        let options = CallOptions(timeout: try! .milliseconds(50))
        let requests = repeatElement(EchoRequest.with { $0.message = "hello" }, count: 3)
        let requestStream = Publishers
            .Sequence<Repeated<EchoRequest>, Error>(sequence: requests)
            .eraseToAnyPublisher()

        let call = GBidirectionalStreamingCall(
            request: GRequestStream(requestStream),
            callOptions: options,
            closure: client.service.noResponse
        )

        call.execute()
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let status):
                        if status.code == .deadlineExceeded {
                            promise.fulfill()
                        } else {
                            XCTFail("Unexpected status: " + status.localizedDescription)
                        }
                    case .finished:
                        XCTFail("Call should not succeed")
                    }
                },
                receiveValue: { _ in
                    XCTFail("Call should not return a response")
                }
            )
            .store(in: &cancellables)

        wait(for: [promise], timeout: 0.2)
    }

    func testClientStreamError() {
        let promise = expectation(description: "Call fails with cancelled status")

        struct ClientStreamError: Error {}
        let requests = Fail<EchoRequest, Error>(error: ClientStreamError()).eraseToAnyPublisher()
        let call = GBidirectionalStreamingCall(
            request: GRequestStream(requests),
            closure: client.service.ok
        )
        call.execute()
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let status):
                        if status.code == .cancelled {
                            promise.fulfill()
                        } else {
                            XCTFail("Unexpected status: " + status.localizedDescription)
                        }
                    case .finished:
                        XCTFail("Call should not succeed")
                    }
                },
                receiveValue: { _ in
                    XCTFail("Call should not return a response")
                }
            )
            .store(in: &cancellables)

        wait(for: [promise], timeout: 0.2)
    }
}

extension BidirectionalStreamingScenariosServiceClient: GRPCClientInitializable {}
