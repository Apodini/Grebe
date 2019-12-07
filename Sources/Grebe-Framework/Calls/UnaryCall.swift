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

class UnaryCall<RequestMessage: Message, ResponseMessage: Message>: ICall {
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
        fatalError()
    }
}
