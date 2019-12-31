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
        let subject = PassthroughSubject<Response, GRPCStatus>()

        let call = callClosure(callOptions) { response in
            subject.send(response)
        }

        request
            .sink(receiveCompletion: { completion in
                switch completion {
                    case .finished: call.sendEnd(promise: nil)
                    case .failure: _ = call.cancel()
                }
            }) { message in
                call.sendMessage(message, promise: nil)
            }
            .store(in: &cancellables)

        call.status.whenSuccess {
            subject.send(completion: $0.code == .ok ? .finished : .failure($0))
        }

        return subject.eraseToAnyPublisher()
    }
}
