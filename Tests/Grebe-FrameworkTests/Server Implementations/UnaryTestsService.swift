//
//  UnaryTestsService.swift
//
//
//  Created by Tim Mewe on 25.12.19.
//

import Combine
import Foundation
@testable import Grebe_Framework
import GRPC
import NIO

class UnaryTestsService: UnaryScenariosProvider {
    func ok(request: EchoRequest, context: StatusOnlyCallContext) -> EventLoopFuture<EchoResponse> {
        context.eventLoop.makeSucceededFuture(EchoResponse.with { $0.message = request.message })
    }

    func failedPrecondition(request: EchoRequest,
                            context: StatusOnlyCallContext) -> EventLoopFuture<Empty> {
        context.eventLoop.makeFailedFuture(GRPCStatus(code: .failedPrecondition, message: "Failed precondition message"))
    }

    func noResponse(request: EchoRequest, context: StatusOnlyCallContext) -> EventLoopFuture<Empty> {
        context.eventLoop.makePromise().futureResult
    }
}
