//
//  ServerStreamingMockClient.swift
//
//
//  Created by Tim Mewe on 10.01.20.
//

import Combine
import GRPC
import NIO
import SwiftProtobuf
import XCTest

internal final class ServerStreamingMockClient<Request: Message & Equatable, Response: Message>: BaseMockClient {
    typealias ServerStreamingMockCall = ServerStreamMock<Request, Response>

    var mockNetworkCalls: [ServerStreamingMockCall] = []
    var cancellables = Set<AnyCancellable>()

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

        networkCall.responseStream
            .sink(receiveCompletion: { completion in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    switch completion {
                    case .failure(let status):
                        unaryMockInboundHandler.respondWithStatus(status)
                    case .finished:
                        unaryMockInboundHandler.respondWithStatus(.ok)
                    }
                }
            }, receiveValue: { message in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    unaryMockInboundHandler.respondWithMock(.success(message))
                }
            })
            .store(in: &self.cancellables)

        return call
    }
}
