//
//  GRPCClientInitializable.swift
//  
//
//  Created by Tim Mewe on 25.12.19.
//

import Foundation
import GRPC

public protocol GRPCClientInitializable: GRPCClient {
    init(connection: ClientConnection, defaultCallOptions: CallOptions)
}
