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
        runTestOk(requests: (0...100).map(EchoRequest.init), response: EchoResponse(id: 1))
    }
    
    func testEmptyRequestStream() {
        runTestOk(requests: [], response: EchoResponse(id: 1))
    }

    private func runTestOk(requests: [Request], response: Response) {
        let clientStreamingMock = ClientStreamMock(
            requests: requests,
            response: .success(response)
        )

        mockClient.mockNetworkCalls = [clientStreamingMock]

        let responseExpectation = XCTestExpectation(description: "Correct Response")
        responseExpectation.expectedFulfillmentCount = 2

        let call = GClientStreamingCall(
            request: clientStreamingMock.requestStream,
            closure: mockClient.test
        )
        call.execute()
            .sinkUnarySucceed(expectedResponse: response, expectation: responseExpectation)
            .store(in: &cancellables)

        wait(for: [clientStreamingMock.expectation, responseExpectation], timeout: 0.1, enforceOrder: true)
    }

    func testFailedPrecondition() {
        let expectedResponse: GRPCStatus = .init(code: .failedPrecondition, message: nil)
        let clientStreamingMock = ClientStreamMock<EchoRequest, EchoResponse>(
            requests: (0...1).map(EchoRequest.init),
            response: .failure(expectedResponse)
        )

        mockClient.mockNetworkCalls = [clientStreamingMock]
        let errorExpectation = XCTestExpectation(description: "Correct Error")

        let call = GClientStreamingCall(
            request: clientStreamingMock.requestStream,
            closure: mockClient.test
        )
        call.execute()
            .sinkUnaryFail(expectedResponse: expectedResponse, expectation: errorExpectation)
            .store(in: &cancellables)

        wait(for: [clientStreamingMock.expectation, errorExpectation], timeout: 0.1, enforceOrder: true)
    }
}
