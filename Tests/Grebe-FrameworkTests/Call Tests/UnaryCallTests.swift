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
import SwiftProtobuf
import XCTest

final class UnaryCallTests: XCTestCase {
    typealias UnaryMockCall = MockNetworkCall<EchoRequest, EchoResponse>
    
    private var mockClient: UnaryServiceMockClient!
    private var cancellables: Set<AnyCancellable> = []
    
    lazy var okMockCall: UnaryMockCall = {
        let request = EchoRequest(id: 1)
        let response: Result<EchoResponse, GRPCError> = Result.success(EchoResponse(id: 1))
        let expectation = XCTestExpectation(description: "Unary call completes successfully")
        return UnaryMockCall(request: request, response: response, expectation: expectation)
    }()
    
    override func setUp() {
        mockClient = UnaryServiceMockClient(mockNetworkCalls: [okMockCall])
    }
    
    override func tearDown() {
        XCTAssert(mockClient.mockNetworkCalls.isEmpty)
        super.tearDown()
    }
    
    func testOk() {
        guard let mockCall = mockClient.mockNetworkCalls.first else {
            XCTFail("No mock network calls left")
            return
        }
        
        let call = GUnaryCall(request: mockCall.request, closure: mockClient.ok)
        var receivedResponse: EchoResponse? = nil
        
        call.execute()
            .sink(
                receiveCompletion: {
                    switch $0 {
                    case .failure(let status):
                        XCTFail("Unexpected status: " + status.localizedDescription)
                    case .finished:
                        XCTAssertNotNil(receivedResponse)
                        XCTAssertEqual(receivedResponse!.id, try! mockCall.response.get().id)
                } },
                receiveValue: { response in
                    receivedResponse = response
                }
            )
            .store(in: &cancellables)
    }
}
