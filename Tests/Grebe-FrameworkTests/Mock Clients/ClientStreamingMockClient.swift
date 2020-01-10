//
//  ClientStreamingMockClient.swift
//  
//
//  Created by Tim Mewe on 10.01.20.
//

import GRPC
import NIO
import SwiftProtobuf
import XCTest

internal final class ClientStreamingMockClient: BaseMockClient, ClientStreamingMockService {
    typealias ClientStreamingMockCall = MockNetworkStream<EchoRequest, EchoResponse>

    var mockNetworkCalls: [ClientStreamingMockCall]

    init(mockNetworkCalls: [ClientStreamingMockCall]) {
        self.mockNetworkCalls = mockNetworkCalls
        super.init()
    }

    func ok(callOptions: CallOptions?) -> ClientStreamingCall<EchoRequest, EchoResponse> {
        let networkCall = mockNetworkCalls.removeFirst()
        networkCall.expectation.fulfill()
        
        let call = ClientStreamingCall<EchoRequest, EchoResponse>(
            connection: connection,
            path: "/ok",
            callOptions: defaultCallOptions,
            errorDelegate: nil
        )
        return call
    }
}
