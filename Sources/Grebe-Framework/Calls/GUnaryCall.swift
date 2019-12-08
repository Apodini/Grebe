//
//  UnaryCall.swift
//
//
//  Created by Tim Mewe on 07.12.19.
//

import Combine
import Foundation
import GRPC
import SwiftProtobuf

class GUnaryCall<RequestMessage: Message, ResponseMessage: Message>: ICall {
    typealias Request = RequestMessage
    typealias Response = ResponseMessage
    typealias CallClosure = (
        _ request: Request,
        _ callOptions: CallOptions?
    ) -> GRPC.UnaryCall<Request, Response>

    internal var request: Request
    internal let callClosure: CallClosure

    init(request: Request, closure: @escaping CallClosure) {
        self.request = request
        self.callClosure = closure
    }

    func execute() -> AnyPublisher<Response, Error> {
        let future = Future<Response, Error> { [weak self] promise in
            guard let strongself = self else { return }
            do {
                let response = try strongself
                    .callClosure(strongself.request, nil)
                    .response
                    .wait()
                promise(.success(response))
            } catch {
                promise(.failure(error))
            }
        }
        
        return future.eraseToAnyPublisher()
    }
}
