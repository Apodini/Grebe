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

final class ClientStreamingCallTests: XCTestCase {
    typealias Request = EchoRequest
    typealias Response = EchoResponse

    var mockClient: ClientStreamingMockClient<Request, Response> = ClientStreamingMockClient()
    private var cancellables: Set<AnyCancellable> = []

    override func setUp() {
        mockClient.mockNetworkCalls = []
        super.setUp()
    }

    override func tearDown() {
        XCTAssert(mockClient.mockNetworkCalls.isEmpty)
        super.tearDown()
    }

    func testOk() {
        let expectedRequests = Publishers.Sequence<[EchoRequest], Error>(
            sequence:
            [EchoRequest.with { $0.id = 0 },
             EchoRequest.with { $0.id = 1 }]
        ).eraseToAnyPublisher()
        let expectedResponse = EchoResponse(id: 1)

        let clientStreamingMock = StreamMock(
            request: expectedRequests,
            response: .success(expectedResponse)
        )

        mockClient.mockNetworkCalls = [clientStreamingMock]

        let responseExpectation = XCTestExpectation(description: "Correct Response")
        responseExpectation.expectedFulfillmentCount = 2

        let call = GClientStreamingCall(request: expectedRequests, closure: mockClient.test)
        call.execute()
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let status):
                        XCTFail("Unexpected status: " + status.localizedDescription)
                    case .finished:
                        responseExpectation.fulfill()
                    }
                },
                receiveValue: { response in
                    XCTAssert(response == expectedResponse)
                    responseExpectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [responseExpectation], timeout: 0.1, enforceOrder: true)
    }
}
