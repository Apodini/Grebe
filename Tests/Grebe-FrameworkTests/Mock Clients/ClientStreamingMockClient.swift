//
//  ClientStreamingMockClient.swift
//
//
//  Created by Tim Mewe on 10.01.20.
//

import Combine
import GRPC
import NIO
import SwiftProtobuf
import XCTest

internal final class ClientStreamingMockClient<Request: Message & Equatable, Response: Message>: BaseMockClient {
    typealias ClientStreamingMockCall = StreamMock<Request, Response>

    var mockNetworkCalls: [ClientStreamingMockCall] = []
    var cancellables = Set<AnyCancellable>()

    func test(callOptions: CallOptions?) -> ClientStreamingCall<Request, Response> {
        let networkCall = mockNetworkCalls.removeFirst()

        let call = ClientStreamingCall<Request, Response>(
            connection: connection,
            path: "/ok",
            callOptions: defaultCallOptions,
            errorDelegate: nil
        )
        channel.embeddedEventLoop.advanceTime(by: .nanoseconds(1))

        let unaryMockInboundHandler = MockInboundHandler<Response>()
        call.subchannel
            .map { subchannel in
                subchannel.pipeline.handler(type: GRPCClientChannelHandler<Request, Response>.self).map { clientChannelHandler in
                    subchannel.pipeline.addHandler(unaryMockInboundHandler, position: .after(clientChannelHandler))
                }
            }.whenSuccess { _ in }

        networkCall.request
            .sink(receiveCompletion: { [weak self] completion in
                self?.channel.embeddedEventLoop.advanceTime(by: .nanoseconds(1))
                switch completion {
                case .failure:
                    unaryMockInboundHandler.respondWithStatus(.processingError)
                case .finished:
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        unaryMockInboundHandler.respondWithMock(networkCall.response)
                        self?.channel.embeddedEventLoop.advanceTime(by: .nanoseconds(1))
                        unaryMockInboundHandler.respondWithStatus(.ok)
                    }
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)

        return call
    }
}
