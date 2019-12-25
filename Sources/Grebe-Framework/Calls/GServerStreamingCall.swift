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

public class GServerStreamingCall<Request: Message, Response: Message>: ICall {
    public typealias CallClosure = (
        _ request: Request,
        _ callOptions: CallOptions?,
        _ handler: @escaping (Response) -> Void
    ) -> GRPC.ServerStreamingCall<Request, Response>
    
    public var request: GRequestMessage<Request>
    public let callClosure: CallClosure
    public let callOptions: CallOptions?
    
    public init(
        request: GRequestMessage<Request>,
        callOptions: CallOptions? = nil,
        closure: @escaping CallClosure
    ) {
        self.request = request
        self.callClosure = closure
        self.callOptions = callOptions
    }
    
    public func execute() -> AnyPublisher<Response, GRPCStatus> {
        let subject = PassthroughSubject<Response, GRPCStatus>()
        
        let call = callClosure(request.message, callOptions) { response in
            subject.send(response)
        }
        
        call.status.whenSuccess {
            subject.send(completion: $0.code == .ok ? .finished : .failure($0))
        }
        
        return subject.eraseToAnyPublisher()
    }
}
