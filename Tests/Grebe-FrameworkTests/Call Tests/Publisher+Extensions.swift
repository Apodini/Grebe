//
//  File.swift
//
//
//  Created by Tim Mewe on 04.02.20.
//

import Combine
import Foundation
import SwiftProtobuf
import XCTest

typealias Response = Message & Equatable

extension Publisher where Self.Output: Response {
    func sinkUnarySucceed(expectedResponse: Self.Output, expectation: XCTestExpectation) -> AnyCancellable {
        return sink(receiveCompletion: {
            switch $0 {
            case .failure(let status):
                XCTFail("Unexpected status: " + status.localizedDescription)
            case .finished:
                expectation.fulfill()
            }
        }, receiveValue: { response in
            XCTAssertEqual(response, expectedResponse)
            expectation.fulfill()
        })
    }
}
