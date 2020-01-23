//
//  UnaryCallTests.swift
//
//
//  Created by Tim Mewe on 25.12.19.
//

import Combine
@testable import Grebe_Framework
import GRPC
import NIO
import XCTest

final class UnaryCallTests: XCTestCase {
    typealias Request = EchoRequest
    typealias Response = EchoResponse
    
    private var mockClient: UnaryMockClient<Request, Response> = UnaryMockClient()
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
        let unaryMock = UnaryMock(request: expectedRequest, response: .success(expectedResponse))
        
        mockClient.mockNetworkCalls = [unaryMock]
        
        let responseExpectation = XCTestExpectation(description: "Correct Response")
        responseExpectation.expectedFulfillmentCount = 2
        
        let call = GUnaryCall(request: expectedRequest, closure: mockClient.test)
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
            }).store(in: &cancellables)
        
        wait(for: [unaryMock.expectation, responseExpectation], timeout: 0.1, enforceOrder: true)
    }
    
    func testFailedPrecondition() {
        let expectedRequest = EchoRequest(id: 1)
        let expectedResponse: GRPCStatus = .init(code: .failedPrecondition, message: nil)
        let unaryMock = UnaryMock<EchoRequest, EchoResponse>(
            request: expectedRequest,
            response: .failure(expectedResponse)
        )
        
        mockClient.mockNetworkCalls = [unaryMock]
        let errorExpectation = XCTestExpectation(description: "Correct Error")
        
        let call = GUnaryCall(request: expectedRequest, closure: mockClient.test)
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
        
        wait(for: [unaryMock.expectation, errorExpectation], timeout: 0.1, enforceOrder: true)
    }
}
