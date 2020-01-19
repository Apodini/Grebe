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

internal final class ServerStreamingMockClient: BaseMockClient, ServerStreamingMockService {
    typealias ServerStreamingMockCall = UnaryMock<EchoRequest, EchoResponse>

    var mockNetworkCalls: [ServerStreamingMockCall]

    init(mockNetworkCalls: [ServerStreamingMockCall]) {
        self.mockNetworkCalls = mockNetworkCalls
        super.init()
    }

    func ok(
        _ request: EchoRequest,
        callOptions: CallOptions?,
        handler: @escaping (EchoResponse) -> Void
    ) -> ServerStreamingCall<EchoRequest, EchoResponse> {
        let networkCall = mockNetworkCalls.removeFirst()

        guard networkCall.request == request else {
            XCTFail("Could not match the network call to the next MockNetworkCall.")
            fatalError()
        }
        networkCall.expectation.fulfill()
        
        let call = ServerStreamingCall<EchoRequest, EchoResponse>(
            connection: connection,
            path: "/ok",
            request: request,
            callOptions: defaultCallOptions,
            errorDelegate: nil,
            handler: handler
        )

        let promise = try! channel.eventLoop.makeSucceededFuture(networkCall.response.get())
        return call
    }
}
