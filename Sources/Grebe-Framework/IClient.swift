//
//  IGrebeClient.swift
//  
//
//  Created by Tim Mewe on 07.12.19.
//

import Combine
import Foundation
import GRPC
import NIO
import SwiftProtobuf

protocol IClient {
    associatedtype Client: GRPCClient
    
    var serviceClient: Client { get }
    var group: EventLoopGroup { get }
}
