//
//  Generator-Grebe.swift
//
//
//  Created by Tim Mewe on 14.01.20.
//

import Foundation

extension Generator {
    internal func printGrebe() {
        println()
//        printClientProtocolConformance()
        println()
        printGrebeImplementation()
    }

    private func printClientProtocolConformance() {
        println("extension \(serviceClassName): GRPCClientInitializable {}")
    }

    private func printGrebeImplementation() {
        println("extension \(serviceClassName): GRPCClientInitializable {")
        indent()
        for method in service.methods {
            self.method = method
            println()
            switch method.stramingType {
                case .unary:
                    println("func \(method.name)(request: \(method.request), callOptions: CallOptions? = defaultCallOptions) -> AnyPublisher<\(method.response), GRPCStatus> {")
                    indent()
                    println("GUnaryCall(request: request, callOptions: callOptions, closure: \(method.callClosure)).execute()")

                case .serverStreaming:
                    println("func \(method.name)(request: \(method.request), callOptions: CallOptions? = defaultCallOptions) -> AnyPublisher<\(method.response), GRPCStatus> {")
                    indent()
                    println("GServerStreamingCall(request: request, callOptions: callOptions, closure: \(method.callClosure)).execute()")

                case .clientStreaming:
                    println("func \(method.name)(request: AnyPublisher<\(method.request),Error> , callOptions: CallOptions? = defaultCallOptions) -> AnyPublisher<\(method.response), GRPCStatus> {")
                    indent()
                    println("GClientStreamingCall(request: request, callOptions: callOptions, closure: \(method.callClosure)).execute()")

                case .bidirectionalStreaming:
                    println("func \(method.name)(request: AnyPublisher<\(method.request),Error> , callOptions: CallOptions? = defaultCallOptions) -> AnyPublisher<\(method.response), GRPCStatus> {")
                    indent()
                    println("GBidirectionalStreamingCall(request: request, callOptions: callOptions, closure: \(method.callClosure)).execute()")
            }
            outdent()
            println("}")
        }
        outdent()
        println("}")
    }
}
