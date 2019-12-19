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

public class GUnaryCall<Request: Message, Response: Message>: ICall {
    public typealias CallClosure = (
        _ request: Request,
        _ callOptions: CallOptions?
    ) -> GRPC.UnaryCall<Request, Response>

    public var request: Request
    public let callClosure: CallClosure

    public init(request: Request, closure: @escaping CallClosure) {
        self.request = request
        self.callClosure = closure
    }

    public func execute() -> AnyPublisher<Response, Error> {
        let future = Future<Response, Error> { [weak self] promise in
            guard let strongself = self else { return }
            
            strongself
                .callClosure(strongself.request, nil)
                .response
                .whenComplete { response in
                    promise(response)
                }
        }
        
        return future.eraseToAnyPublisher()
    }
}
