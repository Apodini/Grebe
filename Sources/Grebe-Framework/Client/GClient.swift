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

public class GClient<Client: GRPCClient>: IClient {    
    public let service: Client
    public let group: EventLoopGroup
    
    init(target: ConnectionTarget) {
        self.group = PlatformSupport.makeEventLoopGroup(loopCount: 1)
        
        let config = ClientConnection.Configuration(target: target, eventLoopGroup: group)
        let connection = ClientConnection(configuration: config)
        service = Client(connection: connection)
    }
}
