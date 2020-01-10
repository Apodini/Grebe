//
//  BaseMockClient.swift
//
//
//  Created by Tim Mewe on 10.01.20.
//

import Foundation
import GRPC
import NIO
import SwiftProtobuf
import XCTest
import Combine

internal struct MockNetworkCall<Request: Message & Equatable, Response: Message> {
    let request: Request
    let response: Result<Response, GRPCError>
    let expectation: XCTestExpectation
}

internal struct MockNetworkStream<Request: Message & Equatable, Response: Message> {
    let request: AnyPublisher<Request, Error>
    let response: Result<Response, GRPCError>
    let expectation: XCTestExpectation
}

internal class BaseMockClient: GRPCClient {
    let eventLoop = EmbeddedEventLoop()
    var connection: ClientConnection
    var defaultCallOptions: CallOptions = CallOptions()
    
    init() {
        connection = ClientConnection(
            configuration: .init(target: .hostAndPort("localhost", 2341),
                                 eventLoopGroup: eventLoop)
        )
    }
}
