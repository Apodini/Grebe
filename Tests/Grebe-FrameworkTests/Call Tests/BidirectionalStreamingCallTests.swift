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
import SwiftProtobuf
import XCTest

final class BidirectionalStreamingCallTests: BaseCallTest {
    var mockClient: BidrectionalStreamingMockClient<Request, Response> = BidrectionalStreamingMockClient()

    override func setUp() {
        mockClient.mockNetworkCalls = []
        super.setUp()
    }

    override func tearDown() {
        XCTAssert(mockClient.mockNetworkCalls.isEmpty)
        super.tearDown()
    }

    func testOk() {
        runTestOk(
            requests: (0...100).map(EchoRequest.init),
            responses: (0...100).map(EchoResponse.init)
        )
    }
    
    func testEmptyResponseStream() {
        runTestOk(requests: (0...1).map(EchoRequest.init), responses: [])
    }
    
    func testEmptyRequestStream() {
        runTestOk(requests: [], responses: (0...1).map(EchoResponse.init))
    }

    private func runTestOk(requests: [Request], responses: [Response]) {
        let bidirectionalStreamingMock = BidirectionalStreamMock(
            requests: requests,
            responses: responses.map { .success($0) },
            requestStream: stream(elements: requests),
            responseStream: stream(elements: responses)
        )

        mockClient.mockNetworkCalls = [bidirectionalStreamingMock]

        let responseExpectation = XCTestExpectation(description: "Correct response count")
        responseExpectation.expectedFulfillmentCount = responses.count + 1

        let call = GBidirectionalStreamingCall(
            requests: bidirectionalStreamingMock.requestStream,
            closure: mockClient.test
        )
        var receivedResponses = [Response]()

        call.execute()
            .sink(receiveCompletion: {
                switch $0 {
                case .failure(let status):
                    XCTFail("Unexpected status: " + status.localizedDescription)
                case .finished:
                    responseExpectation.fulfill()
                    XCTAssertEqual(responses, receivedResponses)
                }
            }, receiveValue: { message in
                receivedResponses.append(message)
                responseExpectation.fulfill()
            })
            .store(in: &cancellables)

        wait(for: [bidirectionalStreamingMock.expectation, responseExpectation], timeout: 0.1, enforceOrder: true)
    }

    private func stream<T: Message, E: Error>(elements: [T]) -> AnyPublisher<T, E> {
        Publishers.Sequence<[T], E>(sequence: elements).eraseToAnyPublisher()
    }
}
