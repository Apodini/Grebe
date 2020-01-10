//
//  UnaryServiceMockClient.swift
//
//
//  Created by Tim Mewe on 10.01.20.
//

import GRPC
import NIO
import SwiftProtobuf
import XCTest

internal final class UnaryServiceMockClient: BaseMockClient, UnaryMockService {
    typealias UnaryMockCall = MockNetworkCall<EchoRequest, EchoResponse>

    var mockNetworkCalls: [UnaryMockCall]

    init(mockNetworkCalls: [UnaryMockCall]) {
        self.mockNetworkCalls = mockNetworkCalls
        super.init()
    }

    func ok(
        _ request: EchoRequest,
        callOptions: CallOptions?
    ) -> UnaryCall<EchoRequest, EchoResponse> {
        let networkCall = mockNetworkCalls.removeFirst()

        guard networkCall.request == request else {
            XCTFail("Could not match the network call to the next MockNetworkCall.")
            fatalError()
        }
        networkCall.rightRequestExpectation.fulfill()
        let unaryCall = UnaryCall<EchoRequest, EchoResponse>(
            connection: connection,
            path: "/ok",
            request: request,
            callOptions: defaultCallOptions,
            errorDelegate: nil
        )

        let promise = try! eventLoop.makeSucceededFuture(networkCall.response.get())
        
        //Assign mocked response to unary call
        //unaryCall.response = promise
        
        return unaryCall
    }
}
