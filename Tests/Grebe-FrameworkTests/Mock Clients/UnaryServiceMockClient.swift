//
//  UnaryServiceMockClient.swift
//
//
//  Created by Tim Mewe on 10.01.20.
//

import XCTest
import NIO
import SwiftProtobuf

@testable import GRPC

internal final class UnaryMockClient<Request: Message & Equatable, Response: Message>: BaseMockClient {
    typealias UnaryMockCall = UnaryMock<Request, Response>

    var mockNetworkCalls: [UnaryMockCall] = []

    func test(_ request: Request, callOptions: CallOptions?) -> UnaryCall<Request, Response> {
        let networkCall = mockNetworkCalls.removeFirst()

        // Check if the Request correspons to the expected Response
        guard networkCall.request == request else {
            XCTFail("Could not match the network call to the next MockNetworkCall.")
            fatalError()
        }
        networkCall.expectation.fulfill()

        // Create our UnaryCall and advance the EventLoop to register all nescessary ChannelHanders
        let call = UnaryCall<Request, Response>(
            connection: connection,
            path: "/test",
            request: request,
            callOptions: defaultCallOptions,
            errorDelegate: nil
        )
        channel.embeddedEventLoop.advanceTime(by: .nanoseconds(1))

        // Creates a subchannel for handling HTTP2 Streams with the following setup:
        //                                                 [I] ↓↑ [O]
        // GRPCClientChannelHandler<EchoRequest, EchoResponse> ↓↑ GRPCClientChannelHandler<EchoRequest, EchoResponse> [handler0]
        // GRPCClientUnaryResponseChannelHandler<EchoResponse> ↓↑                                                     [handler1]
        //             UnaryRequestChannelHandler<EchoRequest> ↓↑                                                     [handler2]
        //
        // We need to inject our `UnaryMockInboundHandler` after the GRPCClientChannelHandler because a
        // GRPCClientChannelHandler has the following Inbound Types:
        //     public typealias InboundIn = HTTP2Frame
        //     public typealias InboundOut = GRPCClientResponsePart<Response>
        // --> We get the subchannel, get the position of the GRPCClientChannelHandler and add our mock handler after that:
        let unaryMockInboundHandler = MockInboundHandler<Response>()
        call.subchannel
            .map { subchannel in
                subchannel.pipeline.handler(type: GRPCClientChannelHandler<Request, Response>.self).map { clientChannelHandler in
                    subchannel.pipeline.addHandler(unaryMockInboundHandler, position: .after(clientChannelHandler))
                }
            }.whenSuccess { _ in }
        channel.embeddedEventLoop.advanceTime(by: .nanoseconds(1))

        // State after injecting our UnaryMockInboundHandler:
        //                                                 [I] ↓↑ [O]
        // GRPCClientChannelHandler<EchoRequest, EchoResponse> ↓↑ GRPCClientChannelHandler<EchoRequest, EchoResponse> [handler0]
        //               UnaryMockInboundHandler<EchoResponse> ↓↑                                                     [handler3]
        // GRPCClientUnaryResponseChannelHandler<EchoResponse> ↓↑                                                     [handler1]
        //             UnaryRequestChannelHandler<EchoRequest> ↓↑                                                     [handler2]

        // Trigger our `fireChannelRead` that is going to propagate inbound.
        unaryMockInboundHandler.respondWithMock(networkCall.response)

        return call
    }
}
