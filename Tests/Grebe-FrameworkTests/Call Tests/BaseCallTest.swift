//
//  BaseCallTest.swift
//
//
//  Created by Tim Mewe on 25.12.19.
//

import Combine
@testable import Grebe_Framework
import GRPC
import NIO
import XCTest

class BaseCallTest: XCTestCase {
    let connectionTarget = ConnectionTarget.hostAndPort("localhost", 30120)

    var serverEventLoopGroup: EventLoopGroup?
    var cancellables: Set<AnyCancellable> = []

    override func setUp() {
        super.setUp()
        serverEventLoopGroup = try! makeTestServer(services: [UnaryTestsService()])
    }

    override func tearDown() {
        try? serverEventLoopGroup?.syncShutdownGracefully()
        cancellables.removeAll()
        super.tearDown()
    }
    
    //MARK: - Helper functions
    
    func makeTestClient<Client>() -> GClient<Client> where Client: GRPCClientInitializable {
        return GClient<Client>(target: connectionTarget)
    }
    
    //MARK: - Private functions

    private func makeTestServer(
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
}
