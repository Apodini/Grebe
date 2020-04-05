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

/// #### A Grebe client
///
/// This client encapsulates a `GRPCClient` that conforms to `GRPCClientInitializable`.
/// The `GRPCClient` is created at initialization. To hide the complexity of a `GRPCClient`
/// the initializer only takes a `ConnectionTarget` and `CallOptions` as parameters.
///
/// ##### Example Usage
/// ```
/// let client = GClient<EchoServiceServiceClient>(target: .hostAndPort("localhost", 62801))
/// ```
public protocol IGClient {
    associatedtype Client: GRPCClientInitializable

    /// The `GRPCClient` this client is using
    var service: Client { get }

    /// The `EventLoopGroup` this client is using.
    var group: EventLoopGroup { get }

    /**
     Creates a Grebe client
     
     - Parameters:
        - target: The target to connect to.
        - callOptions: Options to use for each service call if the user doesn't provide them.
     */
    init(target: ConnectionTarget, callOptions: CallOptions)
}
