//
//  ServerStreamingTestService.swift
//  
//
//  Created by Tim Mewe on 25.12.19.
//

import Combine
import Foundation
@testable import Grebe_Framework
import GRPC
import NIO

class ServerStreamingTestService: ServerStreamingScenariosProvider {
    func ok(request: EchoRequest, context: StreamingResponseCallContext<EchoResponse>) -> EventLoopFuture<GRPCStatus> {
        let responses = repeatElement(EchoResponse.with { $0.message = request.message}, count: 3)
        responses.forEach { _ = context.sendResponse($0) }
        return context.eventLoop.makeSucceededFuture(.ok)
    }
    
    func failedPrecondition(request: EchoRequest, context: StreamingResponseCallContext<Empty>) -> EventLoopFuture<GRPCStatus> {
        context.eventLoop
            .makeFailedFuture(GRPCStatus(code: .failedPrecondition, message: "Failed precondition message"))
    }
    
    func noResponse(request: EchoRequest, context: StreamingResponseCallContext<Empty>) -> EventLoopFuture<GRPCStatus> {
        context.eventLoop.makePromise().futureResult
    }
}
