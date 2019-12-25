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

public protocol ICall {
    associatedtype Request: Message
    associatedtype Response: Message
    associatedtype CallClosure
    
//    var request: (Request) { get }
    var callClosure: CallClosure { get }
    var callOptions: CallOptions? { get }
    
    func execute() -> AnyPublisher<Response, GRPCStatus>
}
