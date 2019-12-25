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
    var client: GClient<UnaryScenariosServiceClient>!
    
    override func setUp() {
        super.setUp()
        serverEventLoopGroup = try! makeTestServer(services: [UnaryTestsService()])
        client = makeTestClient()
    }
    
    override func tearDown() {
        try? client.service.connection.close().wait()
        super.tearDown()
    }
    
    func testOk() {
        let promise = expectation(description: "Call completes successfully")
        
        let testString = "hello"
        let request = GRequestMessage(EchoRequest.with { $0.message = testString })
        let call = GUnaryCall(request: request, closure: client.service.ok)
        
        call.execute()
            .sink(
                receiveCompletion: {
                    switch $0 {
                    case .failure(let status):
                        XCTFail("Unexpected status: " + status.localizedDescription)
                    case .finished:
                        promise.fulfill()
                } },
                receiveValue: { response in
                    XCTAssert(response.message == testString)
                }
            )
            .store(in: &cancellables)
        
        wait(for: [promise], timeout: 0.2)
    }
    
    func testFailedPrecondition() {
        let promise = expectation(description: "Call fails with failed precondition status")
        
        let request = GRequestMessage(EchoRequest.with { $0.message = "hello" })
        let call = GUnaryCall(request: request, closure: client.service.failedPrecondition)
        
        call.execute()
            .sink(
                receiveCompletion: { switch $0 {
                case .failure(let status):
                    if status.code == .failedPrecondition {
                        promise.fulfill()
                    } else {
                        XCTFail("Unexpected status: " + status.localizedDescription)
                    }
                case .finished:
                    XCTFail("Call should not succeed")
                } },
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
        let request = GRequestMessage(EchoRequest.with { $0.message = "hello" })
        let call = GUnaryCall(
            request: request,
            callOptions: options,
            closure: client.service.noResponse
        )
        
        call.execute()
            .sink(
                receiveCompletion: { switch $0 {
                case .failure(let status):
                    if status.code == .deadlineExceeded {
                        promise.fulfill()
                    } else {
                        XCTFail("Unexpected status: " + status.localizedDescription)
                    }
                case .finished:
                    XCTFail("Call should not succeed")
                } },
                receiveValue: { _ in
                    XCTFail("Call should not return a response")
                }
            )
            .store(in: &cancellables)
        
        wait(for: [promise], timeout: 0.2)
    }
}

extension UnaryScenariosServiceClient: GRPCClientInitializable {}
