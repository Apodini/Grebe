//
//  BidrectionalStreamingMockClient.swift
//
//
//  Created by Tim Mewe on 10.01.20.
//

import GRPC
import NIO
import SwiftProtobuf
import XCTest

internal final class BidrectionalStreamingMockClient<Request: Message & Equatable, Response: Message>: BaseMockClient {
    typealias BidirectionalStreamingMockCall = BidirectionalStreamMock<Request, Response>

    var mockNetworkCalls: [BidirectionalStreamingMockCall] = []

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

        var expectedRequests: [Request] = []
        var responses = networkCall.responses

        networkCall.requestStream
            .sink(receiveCompletion: { [weak self] completion in
                XCTAssertEqual(expectedRequests, networkCall.requests)
                switch completion {
                case .failure:
                    unaryMockInboundHandler.respondWithStatus(.processingError)
                    networkCall.expectation.fulfill()
                case .finished:
                    guard expectedRequests == networkCall.requests else {
                        XCTFail("Could not match the network call to the next MockNetworkCall.")
                        fatalError()
                    }
                    networkCall.expectation.fulfill()

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        self?.channel.embeddedEventLoop.advanceTime(by: .nanoseconds(1))
                        unaryMockInboundHandler.respondWithStatus(.ok)
                    }
                }
            }, receiveValue: { request in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    self.channel.embeddedEventLoop.advanceTime(by: .nanoseconds(1))
                    
                    guard !responses.isEmpty else {
                        XCTFail("No response left for given request.")
                        fatalError()
                    }
                    let response = responses.removeFirst()
                    unaryMockInboundHandler.respondWithMock(response)
                    expectedRequests.append(request)
                }
            })
            .store(in: &cancellables)

        return call
    }
}
