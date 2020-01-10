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

struct MockNetworkCall<Request: Message & Equatable, Response: Message> {
    let request: Request
    let response: Response
    let expectation: XCTestExpectation
}

internal final class UnaryServiceMockClient: GRPCClient, UnaryMockService {
    typealias UnaryMockCall = MockNetworkCall<EchoRequest, EchoResponse>

    let eventLoop = EmbeddedEventLoop()
    var connection: ClientConnection

    var defaultCallOptions: CallOptions = CallOptions()
    var mockNetworkCalls: [UnaryMockCall]

    init(mockNetworkCalls: [UnaryMockCall]) {
        self.mockNetworkCalls = mockNetworkCalls
        connection = ClientConnection(
            configuration: .init(target: .hostAndPort("localhost", 2341),
                                 eventLoopGroup: eventLoop)
        )
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
        networkCall.expectation.fulfill()
        let unaryCall = UnaryCall<EchoRequest, EchoResponse>(
            connection: connection,
            path: "/ok",
            request: request,
            callOptions: defaultCallOptions,
            errorDelegate: nil
        )

        let promise: EventLoopFuture<EchoResponse> = eventLoop.makeSucceededFuture(networkCall.response)
        
        //Assign mocked response to unary call
        //unaryCall.response = promise
        
        return unaryCall
    }
}
