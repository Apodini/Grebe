//
//  BaseMockClient.swift
//
//
//  Created by Tim Mewe on 10.01.20.
//

import NIO
import SwiftProtobuf
import XCTest
import Combine

@testable import GRPC

internal struct UnaryMock<Request: Message & Equatable, Response: Message> {
    typealias Request = Request
    typealias Response = Response
    
    let request: Request
    let response: Result<Response, GRPCError>
    let expectation = XCTestExpectation(description: "Request matches the expected UnaryMock Request")
}

internal struct MockNetworkStream<Request: Message & Equatable, Response: Message> {
    let request: AnyPublisher<Request, Error>
    let response: Result<Response, GRPCError>
    let rightResponseExpectation = XCTestExpectation(description: "Right response received")
}

internal class BaseMockClient: GRPCClient {
    let channel = EmbeddedChannel()
    let connection: ClientConnection
    var defaultCallOptions: CallOptions = CallOptions()
    
    init() {
        let configuration = ClientConnection.Configuration.init(target: .socketAddress(.init(sockaddr_un.init())),
                                                                eventLoopGroup: channel.eventLoop)
        connection = ClientConnection(channel: channel, configuration: configuration)
    }
}
