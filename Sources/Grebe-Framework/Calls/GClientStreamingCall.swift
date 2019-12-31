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

    public var request: AnyPublisher<Request, Error>
    public let callClosure: CallClosure
    public let callOptions: CallOptions?

    private var cancellables: Set<AnyCancellable> = []

    public init(
        request: AnyPublisher<Request, Error>,
        callOptions: CallOptions? = nil,
        closure: @escaping CallClosure
    ) {
        self.request = request
        self.callClosure = closure
        self.callOptions = callOptions
    }

    public func execute() -> AnyPublisher<Response, GRPCStatus> {
        let future = Future<Response, GRPCStatus> { [weak self] promise in
            guard let strongself = self else { return }

            let call = strongself.callClosure(strongself.callOptions)
            strongself.request
                .sink(receiveCompletion: { completion in
                    switch completion {
                        case .finished: call.sendEnd(promise: nil)
                        case .failure: _ = call.cancel()
                    }
                }) { message in
                    call.sendMessage(message, promise: nil)
                }
                .store(in: &strongself.cancellables)

            call.response.whenSuccess { promise(.success($0)) }
            call.status.whenSuccess { promise(.failure($0)) }
        }
        return future.eraseToAnyPublisher()
    }
}
