//
//  Client.swift
//  
//
//  Created by Tim Mewe on 07.12.19.
//

import Combine
import Foundation
import GRPC
import NIO
import SwiftProtobuf

/// A Grebe client which wraps a `GRPCClientInitializable` for easier initialization
public class GClient<Client: GRPCClientInitializable>: IGClient {
    public let service: Client
    public let group: EventLoopGroup
    
    /**
     Creates a Grebe client
     
     - Parameters:
        - target: The target to connect to.
        - callOptions: Options to use for each service call if the user doesn't provide them.
     */
    public init(target: ConnectionTarget, callOptions: CallOptions = CallOptions()) {
        self.group = PlatformSupport.makeEventLoopGroup(loopCount: 1)
        
        let config = ClientConnection.Configuration(target: target, eventLoopGroup: group)
        let connection = ClientConnection(configuration: config)
        service = Client(connection: connection, defaultCallOptions: callOptions)
    }
}
