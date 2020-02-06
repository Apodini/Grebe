//
//  BidirectionalStreamingCallTests.swift
//
//
//  Created by Tim Mewe on 27.12.19.
//

import Combine
@testable import Grebe_Framework
import GRPC
import NIO
import XCTest

final class BidirectionalStreamingCallTests: BaseCallTest {
    var mockClient: BidrectionalStreamingMockClient<Request, Response> = BidrectionalStreamingMockClient()

    override func setUp() {
        mockClient.mockNetworkCalls = []
        super.setUp()
    }

    override func tearDown() {
        XCTAssert(mockClient.mockNetworkCalls.isEmpty)
        super.tearDown()
    }
}
