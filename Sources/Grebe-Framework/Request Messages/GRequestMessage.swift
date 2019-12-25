//
//  GRequestMessage.swift
//  
//
//  Created by Tim Mewe on 25.12.19.
//

import Foundation
import GRPC
import NIO
import SwiftProtobuf

public struct GRequestMessage<Request: Message>: IRequestMessage {
    public let message: Request
    
    public init(_ message: Request) {
        self.message = message
    }
}
