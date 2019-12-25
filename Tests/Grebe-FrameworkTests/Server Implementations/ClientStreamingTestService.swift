//
//  ClientStreamingTestService.swift
//
//
//  Created by Tim Mewe on 25.12.19.
//

import Combine
import Foundation
@testable import Grebe_Framework
import GRPC
import NIO

class ClientStreamingTestService: ClientStreamingScenariosProvider {
    func ok(
        context: UnaryResponseCallContext<EchoResponse>
    ) -> EventLoopFuture<(StreamEvent<EchoRequest>) -> Void> {
        var lastRequest: EchoRequest?
        return context.eventLoop.makeSucceededFuture({ event in
            switch event {
            case .message(let request):
                lastRequest = request
            case .end:
                context
                    .responsePromise
                    .succeed(
                        EchoResponse.with { $0.message = lastRequest?.message ?? "no messages" }
                    )
            }
        })
    }

    func failedPrecondition(
        context: UnaryResponseCallContext<Empty>
    ) -> EventLoopFuture<(StreamEvent<EchoRequest>) -> Void> {
        context.eventLoop
            .makeFailedFuture(GRPCStatus(code: .failedPrecondition, message: "Failed precondition message"))
    }

    func noResponse(
        context: UnaryResponseCallContext<Empty>
    ) -> EventLoopFuture<(StreamEvent<EchoRequest>) -> Void> {
        context.eventLoop.makePromise().futureResult
    }
}
