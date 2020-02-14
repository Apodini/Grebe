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
                    println("func \(method.name)(request: \(method.request), callOptions: CallOptions? = nil) -> AnyPublisher<\(method.response), GRPCStatus> {")
                    indent()
                    println("return GUnaryCall(request: request, callOptions: callOptions ?? defaultCallOptions, closure: \(method.callClosure)).execute()")

                case .serverStreaming:
                    println("func \(method.name)(request: \(method.request), callOptions: CallOptions? = nil) -> AnyPublisher<\(method.response), GRPCStatus> {")
                    indent()
                    println("return GServerStreamingCall(request: request, callOptions: callOptions ?? defaultCallOptions, closure: \(method.callClosure)).execute()")

                case .clientStreaming:
                    println("func \(method.name)(request: AnyPublisher<\(method.request),Error> , callOptions: CallOptions? = nil) -> AnyPublisher<\(method.response), GRPCStatus> {")
                    indent()
                    println("return GClientStreamingCall(request: request, callOptions: callOptions ?? defaultCallOptions, closure: \(method.callClosure)).execute()")

                case .bidirectionalStreaming:
                    println("func \(method.name)(request: AnyPublisher<\(method.request),Error> , callOptions: CallOptions? = nil) -> AnyPublisher<\(method.response), GRPCStatus> {")
                    indent()
                    println("return GBidirectionalStreamingCall(requests: request, callOptions: callOptions ?? defaultCallOptions, closure: \(method.callClosure)).execute()")
            }
            outdent()
            println("}")
        }
        outdent()
        println("}")
    }
}
