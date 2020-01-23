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

internal final class BidrectionalStreamingMockClient: BaseMockClient, BidirectionalStreamingMockService {
    typealias BidirectionalStreamingMockCall = StreamMock<EchoRequest, EchoResponse>

    var mockNetworkCalls: [BidirectionalStreamingMockCall]

    init(mockNetworkCalls: [BidirectionalStreamingMockCall]) {
        self.mockNetworkCalls = mockNetworkCalls
        super.init()
    }

    func ok(
        callOptions: CallOptions?,
        handler: @escaping (EchoResponse) -> Void
    ) -> BidirectionalStreamingCall<EchoRequest, EchoResponse> {
        let networkCall = mockNetworkCalls.removeFirst()

        let call = BidirectionalStreamingCall<EchoRequest, EchoResponse>(
            connection: connection,
            path: "/ok",
            callOptions: defaultCallOptions,
            errorDelegate: nil,
            handler: handler
        )
        return call
    }
}
