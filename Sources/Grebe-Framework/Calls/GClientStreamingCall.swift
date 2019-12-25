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

public class GClientStreamingCall<Request: Message, Response: Message>: ICall {
    public typealias CallClosure = (
        _ callOptions: CallOptions?
    ) -> GRPC.ClientStreamingCall<Request, Response>

    public var request: Request
    public let callClosure: CallClosure
    public let callOptions: CallOptions?

    public init(
        request: Request,
        callOptions: CallOptions? = nil,
        closure: @escaping CallClosure
    ) {
        self.request = request
        self.callClosure = closure
        self.callOptions = callOptions
    }

    public func execute() -> AnyPublisher<Response, GRPCStatus> {
//        let future = Future<Response, Error> { [weak self] promise in
//            guard let strongself = self else { return }
//
//            let call = strongself.callClosure(nil)
//
//            call.response.whenSuccess { response in
//                promise(.success(response))
//            }
//
//            call.response.whenFailure { error in
//                promise(.failure(error))
//            }
//        }
//        return future.eraseToAnyPublisher()
        fatalError()
    }
}
