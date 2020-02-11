//
//  CallMocks.swift
//
//
//  Created by Tim Mewe on 11.02.20.
//

import Combine
import NIO
import SwiftProtobuf
import XCTest

@testable import GRPC

internal protocol HasRequestStream {
    associatedtype Request: Message

    var requests: [Request] { get }
    var requestStream: AnyPublisher<Request, Error> { get }
}

extension HasRequestStream {
    var requestStream: AnyPublisher<Request, Error> {
        Publishers.Sequence<[Request], Error>(sequence: requests).eraseToAnyPublisher()
    }
}

internal protocol HasResponseStream {
    associatedtype Response: Message

    var responses: [Result<Response, GRPCStatus>] { get }
    var responseStream: AnyPublisher<Response, GRPCStatus> { get }
}

extension HasResponseStream {
    var responseStream: AnyPublisher<Response, GRPCStatus> {
        var sequence = [Response]()
        for response in responses {
            switch response {
            case .success(let message):
                sequence.append(message)
            case .failure(let status):
                return Fail<Response, GRPCStatus>(error: status).eraseToAnyPublisher()
            }
        }
        return Publishers.Sequence<[Response], GRPCStatus>(sequence: sequence).eraseToAnyPublisher()
    }
}

internal struct UnaryMock<Request: Message & Equatable, Response: Message> {
    let request: Request
    let response: Result<Response, GRPCStatus>
    let expectation = XCTestExpectation(
        description: "Request matches the expected UnaryMock Request"
    )
}

internal struct ClientStreamMock<Request: Message & Equatable, Response: Message>: HasRequestStream {
    let requests: [Request]
    let response: Result<Response, GRPCStatus>
    let expectation = XCTestExpectation(
        description: "Requests match the expected ClientStreamMock requests"
    )
}

internal struct ServerStreamMock<Request: Message & Equatable, Response: Message>: HasResponseStream {
    let request: Request
    let responses: [Result<Response, GRPCStatus>]
    let expectation = XCTestExpectation(
        description: "Request matches the expected ServerStreamMock request"
    )
}

internal struct BidirectionalStreamMock<Request: Message & Equatable, Response: Message>
    : HasRequestStream, HasResponseStream {
    let requests: [Request]
    var responses: [Result<Response, GRPCStatus>]
    let expectation = XCTestExpectation(
        description: "Requests match the expected BidirectionalStreamMock requests"
    )
}
