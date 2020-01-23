//
//  BaseCallTest.swift
//
//
//  Created by Tim Mewe on 25.12.19.
//

import Combine
@testable import Grebe_Framework
import GRPC
import NIO
import XCTest

class BaseCallTest: XCTestCase {
    typealias Request = EchoRequest
    typealias Response = EchoResponse
    
    internal var cancellables: Set<AnyCancellable> = []
}
