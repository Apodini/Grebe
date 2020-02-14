//
//  GRPCClientInitializable.swift
//  
//
//  Created by Tim Mewe on 25.12.19.
//

import Foundation
import GRPC

/// Classes conforming to this protocol can create a `GRPCClient` using a `ClientConnection`
/// and `CallOptions`.
public protocol GRPCClientInitializable: GRPCClient {
    init(connection: ClientConnection, defaultCallOptions: CallOptions)
}
