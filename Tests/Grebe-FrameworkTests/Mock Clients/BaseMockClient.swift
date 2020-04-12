//
//  BaseMockClient.swift
//
//
//  Created by Tim Mewe on 10.01.20.
//

import Combine
import NIO
import SwiftProtobuf
import XCTest

@testable import GRPC

internal class BaseMockClient: GRPCClient {
    let channel = EmbeddedChannel()
    let connection: ClientConnection
    var defaultCallOptions = CallOptions()
    var cancellables = Set<AnyCancellable>()

    init() {
        let configuration = ClientConnection.Configuration(
            target: .socketAddress(.init(sockaddr_un.init())), eventLoopGroup: channel.eventLoop
        )
        connection = ClientConnection(channel: channel, configuration: configuration)
    }
}

/// MockInboundHandler
/// Allows us to inject mock responses into the subchannel pipeline setup by a Call.
internal class MockInboundHandler<Response: Message>: ChannelInboundHandler {
    typealias InboundIn = Any
    typealias InboundOut = GRPCClientResponsePart<Response>

    private var context: ChannelHandlerContext?

    func handlerAdded(context: ChannelHandlerContext) {
        self.context = context
    }

    func respondWithMock(_ mock: Result<Response, GRPCStatus>) {
        let response: GRPCClientResponsePart<Response>
        switch mock {
        case let .success(success):
            response = .message(_Box(success))
        case let .failure(error):
            response = .status(error)
        }

        context?.fireChannelRead(wrapInboundOut(response))
    }

    func respondWithStatus(_ status: GRPCStatus) {
        context?.fireChannelRead(wrapInboundOut(.status(status)))
    }
}
