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

final class UnaryCallTests: BaseCallTest {
    private var mockClient: UnaryMockClient<Request, Response> = UnaryMockClient()
    
    override func setUp() {
        mockClient.mockNetworkCalls = []
        super.setUp()
    }
    
    override func tearDown() {
        XCTAssert(mockClient.mockNetworkCalls.isEmpty)
        super.tearDown()
    }
    
    func testOk() {
        let expectedRequest = EchoRequest(id: 1)
        let expectedResponse = EchoResponse(id: 1)
        let unaryMock = UnaryMock(request: expectedRequest, response: .success(expectedResponse))
        
        mockClient.mockNetworkCalls = [unaryMock]
        
        let responseExpectation = XCTestExpectation(description: "Correct Response")
        responseExpectation.expectedFulfillmentCount = 2
        
        let call = GUnaryCall(request: expectedRequest, closure: mockClient.test)
        call.execute()
            .sinkUnarySucceed(expectedResponse: expectedResponse, expectation: responseExpectation)
            .store(in: &cancellables)
        
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
            .sinkUnaryFail(expectedResponse: expectedResponse, expectation: errorExpectation)
            .store(in: &cancellables)
        
        wait(for: [unaryMock.expectation, errorExpectation], timeout: 0.1, enforceOrder: true)
    }
}
