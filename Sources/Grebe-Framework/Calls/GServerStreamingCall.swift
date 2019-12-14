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
    
    public var request: Request
    public let callClosure: CallClosure

    init(request: Request, closure: @escaping CallClosure) {
        self.request = request
        self.callClosure = closure
    }
    
    public func execute() -> AnyPublisher<Response, Error> {
        let subject = PassthroughSubject<Response, Error>()
        
        let call = callClosure(request, nil) { response in
            subject.send(response)
        }
        
        let status = try! call.status.recover { _ in .processingError }.wait()
        if status != .ok {
            subject.send(completion: .failure(GRPCStatus.processingError))
        }
        
        return subject.eraseToAnyPublisher()
    }
}
