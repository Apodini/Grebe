//
//  ExampleUsage.swift
//
//
//  Created by Tim Mewe on 07.12.19.
//

import Foundation
import GRPC
import NIO

class ExampleUsage {
    private let client: TaskServiceServiceClient

    init() {
        let group = PlatformSupport.makeEventLoopGroup(loopCount: 1)
        let config = ClientConnection.Configuration(
            target: .hostAndPort("localhost", 1234),
            eventLoopGroup: group
        )
        client = TaskServiceServiceClient(connection: .init(configuration: config))
    }

    private func unaryCall() {
        let call = GUnaryCall(request: GetTaskRequest(), closure: client.getTask)
        call.execute()
            .sink(receiveCompletion: { _ in
                print("Unary call completed")
            },
                  receiveValue: { value in
                print("Unary call received value: \(value)")
            })
    }
}
