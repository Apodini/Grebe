//
//  TestUtils.swift
//  
//
//  Created by Tim Mewe on 25.12.19.
//

import Combine
@testable import Grebe_Framework
import GRPC
import NIO
import XCTest

let connectionTarget = ConnectionTarget.hostAndPort("localhost", 30120)

func makeTestClient<Client>() -> GClient<Client> where Client: GRPCClientInitializable {
    return GClient<Client>(target: connectionTarget)
}

func makeTestServer(
    services: [CallHandlerProvider],
    eventLoopGroupSize: Int = 1
) throws -> EventLoopGroup {
    let eventLoopGroup = PlatformSupport.makeEventLoopGroup(loopCount: eventLoopGroupSize)
    let configuration = Server.Configuration(
        target: connectionTarget,
        eventLoopGroup: eventLoopGroup,
        serviceProviders: services
    )
    _ = try Server.start(configuration: configuration).wait()
    return eventLoopGroup
}
