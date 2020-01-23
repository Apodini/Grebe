//
//  ServerStreamingMockClient.swift
//
//
//  Created by Tim Mewe on 10.01.20.
//

import GRPC
import NIO
import SwiftProtobuf
import XCTest

internal final class ServerStreamingMockClient<Request: Message & Equatable, Response: Message>: BaseMockClient {
    typealias ServerStreamingMockCall = UnaryMock<Request, Response>

    var mockNetworkCalls: [ServerStreamingMockCall] = []

    func test(
        _ request: Request,
        callOptions: CallOptions?,
        handler: @escaping (Response) -> Void
    ) -> ServerStreamingCall<Request, Response> {
        let networkCall = mockNetworkCalls.removeFirst()

        guard networkCall.request == request else {
            XCTFail("Could not match the network call to the next MockNetworkCall.")
            fatalError()
        }
        networkCall.expectation.fulfill()

        let call = ServerStreamingCall<Request, Response>(
            connection: connection,
            path: "/test",
            request: request,
            callOptions: defaultCallOptions,
            errorDelegate: nil,
            handler: handler
        )

        channel.embeddedEventLoop.advanceTime(by: .nanoseconds(1))

        let unaryMockInboundHandler = MockInboundHandler<Response>()
        call.subchannel
            .map { subchannel in
                subchannel.pipeline.handler(type: GRPCClientChannelHandler<Request, Response>.self).map { clientChannelHandler in
                    subchannel.pipeline.addHandler(unaryMockInboundHandler, position: .after(clientChannelHandler))
                }
            }.whenSuccess { _ in }
        channel.embeddedEventLoop.advanceTime(by: .nanoseconds(1))

        unaryMockInboundHandler.respondWithMock(networkCall.response)
        channel.embeddedEventLoop.advanceTime(by: .nanoseconds(1))
        unaryMockInboundHandler.respondWithStatus(.ok)

        return call
    }
}
