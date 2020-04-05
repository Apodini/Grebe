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

/// Implementation of `IGClient`.
public class GClient<Client: GRPCClientInitializable>: IGClient {
    public let service: Client
    public let group: EventLoopGroup

    required public init(target: ConnectionTarget, callOptions: CallOptions = CallOptions()) {
        self.group = PlatformSupport.makeEventLoopGroup(loopCount: 1)

        let config = ClientConnection.Configuration(target: target, eventLoopGroup: group)
        let connection = ClientConnection(configuration: config)
        service = Client(connection: connection, defaultCallOptions: callOptions)
    }
}
