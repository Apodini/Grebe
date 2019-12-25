//
//  GRequestStream.swift
//  
//
//  Created by Tim Mewe on 25.12.19.
//

import Foundation
import GRPC
import NIO
import SwiftProtobuf
import Combine

public struct GRequestStream<Request: Message>: IRequestStream {
    public let stream: AnyPublisher<Request, Error>
    
    public init(_ stream: AnyPublisher<Request, Error>) {
        self.stream = stream
    }
}
