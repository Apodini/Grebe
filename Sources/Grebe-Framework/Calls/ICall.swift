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

/// Base protocol for a Grebe call to a gRPC service.
public protocol ICall {
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
