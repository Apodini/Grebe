//
//  BidirectionalStreamingTestService.swift
//
//
//  Created by Tim Mewe on 27.12.19.
//

import Combine
import Foundation
@testable import Grebe_Framework
import GRPC
import NIO

class BidirectionalStreamingTestService: BidirectionalStreamingScenariosProvider {
    func ok(
        context: StreamingResponseCallContext<EchoResponse>
    ) -> EventLoopFuture<(StreamEvent<EchoRequest>) -> Void> {
        context.eventLoop.makeSucceededFuture({ event in
            switch event {
            case .message(let note):
                _ = context.sendResponse(EchoResponse.with { $0.message = note.message })
            case .end:
                context.statusPromise.succeed(.ok)
            }
        })
    }

    func failedPrecondition(
        context: StreamingResponseCallContext<Empty>
    ) -> EventLoopFuture<(StreamEvent<EchoRequest>) -> Void> {
        context.eventLoop
            .makeFailedFuture(GRPCStatus(code: .failedPrecondition, message: "Failed precondition message"))
    }

    func noResponse(
        context: StreamingResponseCallContext<Empty>
    ) -> EventLoopFuture<(StreamEvent<EchoRequest>) -> Void> {
        context.eventLoop.makePromise().futureResult
    }
}
