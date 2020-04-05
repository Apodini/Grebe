//
//  GUnaryCall.swift
//
//
//  Created by Tim Mewe on 07.12.19.
//

import Combine
import Foundation
import GRPC
import SwiftProtobuf

/// #### A unary Grebe call.
///
/// The client sends a single request to the server and gets a single response back, just like a normal function call.
///
/// ##### Example usage of `GUnaryCall`
///
/// Consider the following protobuf definition for a simple echo service.
/// The service defines one unary RPC. You send one message and it
/// echoes the message back to you.
///
/// ```proto
/// syntax = "proto3";
///
/// service EchoService {
///     rpc echo (EchoRequest) returns (EchoResponse);
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
/// You can create a `GUnaryCall` like this:
/// ```
/// GUnaryCall(request: EchoRequest.with { $0.message = "hello"}, closure: echo)
/// ```
///

public class GUnaryCall<Request: Message, Response: Message>: IGCall {
    public typealias CallClosure = (
        _ request: Request,
        _ callOptions: CallOptions?
    ) -> GRPC.UnaryCall<Request, Response>

    /// The request message for the call.
    public var request: Request
    public let callClosure: CallClosure
    public let callOptions: CallOptions?

    /**
     Sets up an new unary Grebe call.

     - Parameters:
        - request: The request message for the call.
        - callOptions: Options to use for each service call.
        - closure: The closure which contains the executable call.
     */
    public init(
        request: Request,
        callOptions: CallOptions? = nil,
        closure: @escaping CallClosure
    ) {
        self.request = request
        self.callClosure = closure
        self.callOptions = callOptions
    }

    /**
     Executes the Grebe unary call.

     - Returns: A stream of `Response` elements. The response publisher may fail
                with a `GRPCStatus` error.
     */
    public func execute() -> AnyPublisher<Response, GRPCStatus> {
        let future = Future<Response, GRPCStatus> { [weak self] promise in
            guard let strongself = self else {
                return
            }

            let call = strongself
                .callClosure(strongself.request, strongself.callOptions)

            call.response.whenSuccess { promise(.success($0)) }
            call.status.whenSuccess { promise(.failure($0)) }
        }

        return future.eraseToAnyPublisher()
    }
}
