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

final class ServerStreamingCallTests: BaseCallTest {
    private var mockClient: ServerStreamingMockClient<Request, Response> = ServerStreamingMockClient()
    
    override func setUp() {
        mockClient.mockNetworkCalls = []
        super.setUp()
    }
    
    override func tearDown() {
        XCTAssert(mockClient.mockNetworkCalls.isEmpty)
        super.tearDown()
    }
    
    func testOk() {
        runTestOk(request: EchoRequest(id: 1), responses: (0...100).map(EchoResponse.init))
    }
    
    func testEmptyResponseStream() {
        runTestOk(request: EchoRequest(id: 1), responses: [])
    }
    
    private func runTestOk(request: Request, responses: [Response]) {
        let expectedResponseStream = Publishers.Sequence<[EchoResponse], GRPCStatus>(
            sequence: responses
        ).eraseToAnyPublisher()
        let serverStreamingMock = ServerStreamMock(
            request: request,
            responses: responses.map { .success($0) },
            responseStream: expectedResponseStream
        )
        
        mockClient.mockNetworkCalls = [serverStreamingMock]
        
        let responseExpectation = XCTestExpectation(description: "Correct response count")
        responseExpectation.expectedFulfillmentCount = responses.count + 1
        
        let call = GServerStreamingCall(request: request, closure: mockClient.test)
        var receivedResponses = [Response]()
        call.execute()
            .sink(
                receiveCompletion: {
                    switch $0 {
                    case .failure(let status):
                        XCTFail("Unexpected status: " + status.localizedDescription)
                    case .finished:
                        responseExpectation.fulfill()
                        XCTAssertEqual(responses, receivedResponses)
                    }
                },
                receiveValue: { message in
                    receivedResponses.append(message)
                    responseExpectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        wait(for: [serverStreamingMock.expectation, responseExpectation], timeout: 0.1, enforceOrder: true)
    }
    
    func testFailedPrecondition() {
        let expectedRequest = EchoRequest(id: 1)
        let errorStatus: GRPCStatus = .init(code: .failedPrecondition, message: nil)
        let expectedResponseStream = Fail<EchoResponse, GRPCStatus>(
            error: errorStatus
        ).eraseToAnyPublisher()
        let serverStreamingMock = ServerStreamMock(
            request: expectedRequest,
            responses: [.failure(errorStatus)],
            responseStream: expectedResponseStream
        )
        
        mockClient.mockNetworkCalls = [serverStreamingMock]
        let errorExpectation = XCTestExpectation(description: "Correct Error")
        
        let call = GServerStreamingCall(request: expectedRequest, closure: mockClient.test)
        call.execute()
            .sink(receiveCompletion: {
                switch $0 {
                case .failure(let status):
                    XCTAssertEqual(status, errorStatus)
                    errorExpectation.fulfill()
                case .finished:
                    XCTFail("Call should fail")
                }
            }, receiveValue: { _ in
                XCTFail("Call should fail")
            }).store(in: &cancellables)
        
        wait(for: [serverStreamingMock.expectation, errorExpectation], timeout: 0.1, enforceOrder: true)
    }
}
