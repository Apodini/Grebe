//
//  GBidirectionalStreamingCall.swift
//
//
//  Created by Tim Mewe on 07.12.19.
//

import Combine
import Foundation
import GRPC
import SwiftProtobuf

/// #### A bidirectional streaming Grebe call.
///
/// Both sides, the client and the server, send a sequence of messages. The two streams
/// operate independently, so clients and servers can read and write and whatever
/// oder they like: for example, the server could wait to receive all the client messages
/// before writing its responses, or it could alternately read a message then write a
/// message, or some other combination of reads and writes.
///
/// ##### Example usage of `GBidirectionalStreamingCall`
///
/// Consider the following protobuf definition for a simple echo service.
/// The service defines one bidirectional streaming RPC. You send a stream of messages and it
/// echoes a stream of messages back to you.
///
/// ```proto
/// syntax = "proto3";
///
/// service EchoService {
///     rpc echo (stream EchoRequest) returns (stream EchoResponse);
/// }
///
/// message EchoRequest {
///     string message = 1;
/// }
///
/// message EchoResponse {
///     string message = 1;
/// }
/// ```
///
/// You can create a `GBidirectionalStreamingCall` like this:
/// ```
/// let requests = Publishers.Sequence<[EchoRequest], Error>(
///     sequence: [EchoRequest.with { $0.message = "hello"}, EchoRequest.with { $0.message = "world"}]
/// ).eraseToAnyPublisher()
///
/// GBidirectionalStreamingCall(request: requests, callOptions: callOptions, closure: echo)
/// ```
///
public class GBidirectionalStreamingCall<Request: GRPCPayload, Response: GRPCPayload>: IGCall {
    public typealias CallClosure = (
        _ callOptions: CallOptions?,
        _ handler: @escaping (Response) -> Void
    ) -> GRPC.BidirectionalStreamingCall<Request, Response>

    /// The request message stream for the call.
    public var requests: AnyPublisher<Request, Error>
    public let callClosure: CallClosure
    public let callOptions: CallOptions?

    /// Stores all cacellables.
    private var cancellables: Set<AnyCancellable> = []

    /**
    Sets up an new bidirectional streaming Grebe call.

    - Parameters:
       - request: The request message stream for the call.
       - callOptions: Options to use for each service call.
       - closure: The closure which contains the executable call.
    */
    public init(
        requests: AnyPublisher<Request, Error>,
        callOptions: CallOptions? = nil,
        closure: @escaping CallClosure
    ) {
        self.requests = requests
        self.callClosure = closure
        self.callOptions = callOptions
    }

    /**
    Executes the Grebe bidirectional streaming call.

    - Returns: A stream of `Response` elements. The response publisher may fail
               with a `GRPCStatus` error.
    */
    public func execute() -> AnyPublisher<Response, GRPCStatus> {
        let subject = PassthroughSubject<Response, GRPCStatus>()

        let call = callClosure(callOptions) { response in
            subject.send(response)
        }

        requests
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    call.sendEnd(promise: nil)
                case .failure:
                    _ = call.cancel()
                }
            }, receiveValue: { message in
                call.sendMessage(message, promise: nil)
            })
            .store(in: &cancellables)

        call.status.whenSuccess {
            subject.send(completion: $0.code == .ok ? .finished : .failure($0))
        }

        return subject.eraseToAnyPublisher()
    }
}
