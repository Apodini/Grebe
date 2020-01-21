//
//  ServerStreamingCallTests.swift
//
//
//  Created by Tim Mewe on 25.12.19.
//

import Combine
@testable import Grebe_Framework
import GRPC
import NIO
import XCTest

final class ServerStreamingCallTests: XCTestCase {
    typealias Request = EchoRequest
    typealias Response = EchoResponse
    
    private var mockClient: ServerStreamingMockClient<Request, Response> = ServerStreamingMockClient()
    private var cancellables: Set<AnyCancellable> = []
    
    override func setUp() {
        mockClient.mockNetworkCalls = []
        super.setUp()
    }
    
    override func tearDown() {
        XCTAssert(mockClient.mockNetworkCalls.isEmpty)
        super.tearDown()
    }
    
    func test() {
        let expectedRequest = EchoRequest(id: 1)
        let expectedResponse = EchoResponse(id: 1)
        let serverStreamingMock = ServerStreamingMock(request: expectedRequest, response: .success(expectedResponse))
        
        mockClient.mockNetworkCalls = [serverStreamingMock]
        
        let responseExpectation = XCTestExpectation(description: "Correct Response")
        responseExpectation.expectedFulfillmentCount = 2
        
        let call = GServerStreamingCall(request: expectedRequest, closure: mockClient.test)
        
        call.execute()
            .sink(
                receiveCompletion: {
                    switch $0 {
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
        
        wait(for: [serverStreamingMock.expectation, responseExpectation], timeout: 0.1, enforceOrder: true)
    }
}
