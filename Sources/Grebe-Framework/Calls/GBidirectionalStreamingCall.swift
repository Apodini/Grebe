//
//  BidirectionalStreamingCall.swift
//  
//
//  Created by Tim Mewe on 07.12.19.
//

import Combine
import Foundation
import GRPC
import SwiftProtobuf

public class GBidirectionalStreamingCall<Request: Message, Response: Message>: ICall {
    public typealias CallClosure = (
        _ callOptions: CallOptions?,
        _ handler: @escaping (Response) -> Void
        ) -> GRPC.BidirectionalStreamingCall<Request, Response>
        
    public var request: Request
    public let callClosure: CallClosure

    init(request: Request, closure: @escaping CallClosure) {
        self.request = request
        self.callClosure = closure
    }
    
    public func execute() -> AnyPublisher<Response, Error> {
        fatalError()
    }
}
