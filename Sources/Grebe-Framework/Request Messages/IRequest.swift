//
//  IRequest.swift
//  
//
//  Created by Tim Mewe on 25.12.19.
//

import Foundation
import GRPC
import NIO
import SwiftProtobuf
import Combine

public protocol IRequest {
    associatedtype Request: Message
}

public protocol IRequestMessage: IRequest {
    var message: Request { get }
}

public protocol IRequestStream: IRequest {
    var stream: AnyPublisher<Request, Error> { get }
}
