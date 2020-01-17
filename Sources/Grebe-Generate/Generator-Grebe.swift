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
        printClientProtocolConformance()
        println()
        printGrebeImplementation()
    }

    private func printClientProtocolConformance() {
        println("extension \(serviceClassName): GRPCClientInitializable {}")
    }

    private func printGrebeImplementation() {
        for method in service.methods {
            self.method = method
            switch method.stramingType {
                case .unary:
                    println("func \(method.name)(request: \(method.request), callOptions: CallOptions?, callClosure: CallClosure) -> AnyPublisher<\(method.response), GRPCStatus> {")
                    indent()
                    println("GUnaryCall(request: request, callOptions: callOptions, closure: callClosure).execute()")

                case .serverStreaming:
                    println("func \(method.name)(request: \(method.request), callOptions: CallOptions?, callClosure: CallClosure) -> AnyPublisher<\(method.response), GRPCStatus> {")
                    indent()
                    println("GServerStreamingCall(request: request, callOptions: callOptions, closure: callClosure).execute()")

                case .clientStreaming:
                    println("func \(method.name)(request: AnyPublisher<\(method.request),Error> , callOptions: CallOptions?, callClosure: CallClosure) -> AnyPublisher<\(method.response), GRPCStatus> {")
                    indent()
                    println("GClientStreamingCall(request: request, callOptions: callOptions, closure: callClosure).execute()")

                case .bidirectionalStreaming:
                    println("func \(method.name)(request: AnyPublisher<\(method.request),Error> , callOptions: CallOptions?, callClosure: CallClosure) -> AnyPublisher<\(method.response), GRPCStatus> {")
                    indent()
                    println("GBidirectionalStreamingCall(request: request, callOptions: callOptions, closure: callClosure).execute()")
            }
            outdent()
            println("}")
            println()
        }
    }
}
