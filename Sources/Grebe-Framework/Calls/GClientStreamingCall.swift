//
//  ClientStreamingCall.swift
//  
//
//  Created by Tim Mewe on 07.12.19.
//

import Combine
import Foundation
import GRPC
import SwiftProtobuf

class GClientStreamingCall<RequestMessage: Message, ResponseMessage: Message>: ICall {
    typealias Request = RequestMessage
    typealias Response = ResponseMessage
    typealias CallClosure = (
        _ callOptions: CallOptions?
        ) -> GRPC.ClientStreamingCall<Request, Response>
    
    internal var request: Request
    internal let callClosure: CallClosure

    init(request: Request, closure: @escaping CallClosure) {
        self.request = request
        self.callClosure = closure
    }
    
    func execute() -> AnyPublisher<Response, Error> {
        let future = Future<Response, Error> { [weak self] promise in
            guard let strongself = self else { return }
            
            let call = strongself.callClosure(nil)
            
            call.response.whenSuccess { response in
                promise(.success(response))
            }
            
            call.response.whenFailure { error in
                promise(.failure(error))
            }
        }
        return future.eraseToAnyPublisher()
    }
}
