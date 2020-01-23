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

internal struct UnaryMock<Request: Message & Equatable, Response: Message> {
    let request: Request
    let response: Result<Response, GRPCStatus>
    let expectation = XCTestExpectation(description: "Request matches the expected UnaryMock Request")
}

internal struct StreamMock<Request: Message & Equatable, Response: Message> {
    let request: AnyPublisher<Request, Error>
    let response: Result<Response, GRPCStatus>
}

internal class BaseMockClient: GRPCClient {
    let channel = EmbeddedChannel()
    let connection: ClientConnection
    var defaultCallOptions: CallOptions = CallOptions()

    init() {
        let configuration = ClientConnection.Configuration(target: .socketAddress(.init(sockaddr_un.init())),
                                                           eventLoopGroup: channel.eventLoop)
        connection = ClientConnection(channel: channel, configuration: configuration)
    }
}
