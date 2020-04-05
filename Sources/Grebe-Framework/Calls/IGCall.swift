//
//  ICall.swift
//
//
//  Created by Tim Mewe on 07.12.19.
//

import Combine
import Foundation
import GRPC
import SwiftProtobuf
import NIO

/// #### Base protocol for a Grebe call to a gRPC service.
///
/// gRPC lets you define four kinds of service method:
/// - Unary RPCs (`GUnaryCall`)
/// - Server streaming RPCs (`GServerStreamingCall`)
/// - Client streaming RPCs (`GClientStreamingCall`)
/// - Bidirectional streaming RPCs (`GBidirectionalStreamingCall`)
///
/// To run an instance of `ICall`, call the `execute` method of the specific call.
///
public protocol IGCall {
    /// The type of the request message for the call.
    associatedtype Request: Message
    /// The type of the response message for the call.
    associatedtype Response: Message
    /// The type of the call closure for the call.
    associatedtype CallClosure

    /// The closure which contains the executable call.
    var callClosure: CallClosure { get }
    /// Options to use for each service call.
    var callOptions: CallOptions? { get }

    /// Executes the current call
    func execute() -> AnyPublisher<Response, GRPCStatus>
}
