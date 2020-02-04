//
//  ClientStreamingCallTests.swift
//
//
//  Created by Tim Mewe on 25.12.19.
//

import Combine
@testable import Grebe_Framework
import GRPC
import NIO
import XCTest

final class ClientStreamingCallTests: BaseCallTest {
    var mockClient: ClientStreamingMockClient<Request, Response> = ClientStreamingMockClient()

    override func setUp() {
        mockClient.mockNetworkCalls = []
        super.setUp()
    }

    override func tearDown() {
        XCTAssert(mockClient.mockNetworkCalls.isEmpty)
        super.tearDown()
    }

    func testOk() {
        let requests = [EchoRequest(id: 0), EchoRequest(id: 1)]
        let expectedRequests = Publishers.Sequence<[EchoRequest], Error>(
            sequence: requests
        ).eraseToAnyPublisher()
        let expectedResponse = EchoResponse(id: 1)

        let clientStreamingMock = ClientStreamMock(
            requests: requests,
            requestStream: expectedRequests,
            response: .success(expectedResponse)
        )

        mockClient.mockNetworkCalls = [clientStreamingMock]

        let responseExpectation = XCTestExpectation(description: "Correct Response")
        responseExpectation.expectedFulfillmentCount = 2

        let call = GClientStreamingCall(request: expectedRequests, closure: mockClient.test)
        call.execute()
            .sink(receiveCompletion: {
                switch $0 {
                case .failure(let status):
                    XCTFail("Unexpected status: " + status.localizedDescription)
                case .finished:
                    responseExpectation.fulfill()
                }
            }, receiveValue: { response in
                XCTAssertEqual(response, expectedResponse)
                responseExpectation.fulfill()
            })
            .store(in: &cancellables)

        wait(for: [clientStreamingMock.expectation, responseExpectation], timeout: 0.1, enforceOrder: true)
    }

    func testFailedPrecondition() {
        let requests = [EchoRequest(id: 0), EchoRequest(id: 1)]
        let expectedRequests = Publishers.Sequence<[EchoRequest], Error>(
            sequence: requests
        ).eraseToAnyPublisher()
        let expectedResponse: GRPCStatus = .init(code: .failedPrecondition, message: nil)

        let clientStreamingMock = ClientStreamMock<EchoRequest, EchoResponse>(
            requests: requests,
            requestStream: expectedRequests,
            response: .failure(expectedResponse)
        )

        mockClient.mockNetworkCalls = [clientStreamingMock]
        let errorExpectation = XCTestExpectation(description: "Correct Error")

        let call = GClientStreamingCall(request: expectedRequests, closure: mockClient.test)
        call.execute()
            .sink(receiveCompletion: {
                switch $0 {
                case .failure(let status):
                    XCTAssertEqual(status, expectedResponse)
                    errorExpectation.fulfill()
                case .finished:
                    XCTFail("Call should fail")
                }
            }, receiveValue: { _ in
                XCTFail("Call should fail")
            }).store(in: &cancellables)

        wait(for: [clientStreamingMock.expectation, errorExpectation], timeout: 0.1, enforceOrder: true)
    }
}
