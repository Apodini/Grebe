//
//  GClientStreamingCall.swift
//
//
//  Created by Tim Mewe on 07.12.19.
//

import Combine
import Foundation
import GRPC
import SwiftProtobuf

/// A client streaming Grebe call.
///
/// The client sends a sequence of request messages to the server. Once the client
/// has finished writing the messages it waits for the server to read them and
/// return its response
///
/// ### Example usage of `GClientStreamingCall`
///
/// Consider the following protobuf definition for a simple echo service.
/// The service defines one client streaming RPC. You send a stream of messages and it
/// sends one messages back to you.
///
/// ```proto
/// syntax = "proto3";
///
/// service EchoService {
///     rpc echo (stream EchoRequest) returns (EchoResponse);
/// }
///
/// message EchoRequest {
///     string message = 1;
/// }
///
/// message EchoResponse {
///     string message = 1;
/// }
///```
///
/// You can create a `GClientStreamingCall` like this:
/// ```
/// let requests = Publishers.Sequence<[EchoRequest], Error>(
///     sequence: [EchoRequest.with { $0.message = "hello"}, EchoRequest.with { $0.message = "world"}]
/// ).eraseToAnyPublisher()
/// 
/// GClientStreamingCall(request: requests, callOptions: callOptions, closure: echo)
/// ```
///
public class GClientStreamingCall<Request: Message, Response: Message>: ICall {
    public typealias CallClosure = (
        _ callOptions: CallOptions?
    ) -> GRPC.ClientStreamingCall<Request, Response>

    /// The request message stream for the call.
    public var request: AnyPublisher<Request, Error>
    public let callClosure: CallClosure
    public let callOptions: CallOptions?

    /// Stores all cacellables.
    private var cancellables: Set<AnyCancellable> = []

    /**
       Sets up an new client streaming Grebe call.

       - Parameters:
          - request: The request message stream for the call.
          - callOptions: Options to use for each service call.
          - closure: The closure which contains the executable call.
       */
    public init(
        request: AnyPublisher<Request, Error>,
        callOptions: CallOptions? = nil,
        closure: @escaping CallClosure
    ) {
        self.request = request
        self.callClosure = closure
        self.callOptions = callOptions
    }

    /**
       Executes the Grebe client streaming call.

       - Returns: A stream of `Response` elements. The response publisher may fail
                  with a `GRPCStatus` error.
       */
    public func execute() -> AnyPublisher<Response, GRPCStatus> {
        let subject = PassthroughSubject<Response, GRPCStatus>()
        let call = callClosure(callOptions)

        request
            .sink(receiveCompletion: { completion in
                switch completion {
                    case .finished: call.sendEnd(promise: nil)
                    case .failure: _ = call.cancel()
                }
            }) { message in
                call.sendMessage(message, promise: nil)
            }
            .store(in: &cancellables)

        call.response.whenSuccess {
            subject.send($0)
        }
        call.status.whenSuccess {
            subject.send(completion: $0.code == .ok ? .finished : .failure($0))
        }

        return subject.eraseToAnyPublisher()
    }
}
