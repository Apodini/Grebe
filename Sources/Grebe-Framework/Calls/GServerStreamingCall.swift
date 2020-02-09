//
//  ServerStreamingCall.swift
//
//
//  Created by Tim Mewe on 07.12.19.
//

import Combine
import Foundation
import GRPC
import SwiftProtobuf

/// A server streaming Grebe call.
public class GServerStreamingCall<Request: Message, Response: Message>: ICall {
    public typealias CallClosure = (
        _ request: Request,
        _ callOptions: CallOptions?,
        _ handler: @escaping (Response) -> Void
    ) -> GRPC.ServerStreamingCall<Request, Response>
    
    /// The request message for the call.
    public var request: Request
    public let callClosure: CallClosure
    public let callOptions: CallOptions?
    
    /**
        Sets up an new server streaming Grebe call.
     
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
    Executes the Grebe server streaming call.

    - Returns: A stream of `Response` elements. The response publisher may fail
               with a `GRPCStatus` error.
    */
    public func execute() -> AnyPublisher<Response, GRPCStatus> {
        let subject = PassthroughSubject<Response, GRPCStatus>()
        
        let call = callClosure(request, callOptions) { response in
            subject.send(response)
        }
        
        call.status.whenSuccess {
            subject.send(completion: $0.code == .ok ? .finished : .failure($0))
        }
        
        return subject.eraseToAnyPublisher()
    }
}
