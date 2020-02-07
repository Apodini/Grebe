//
//  IClient.swift
//  
//
//  Created by Tim Mewe on 07.12.19.
//

import Combine
import Foundation
import GRPC
import NIO
import SwiftProtobuf

/// A Grebe client
public protocol IGClient {
    associatedtype Client: GRPCClient
    
    /// The `GRPCClient` this client is using
    var service: Client { get }
    
    /// The `EventLoopGroup` this client is using.
    var group: EventLoopGroup { get }
}
