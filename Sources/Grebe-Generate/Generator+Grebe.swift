//
//  File.swift
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
            switch streamingType(method) {
                case .unary:
                    println("func \(methodFunctionName)(request: \(methodInputName), callOptions: CallOptions?, callClosure: CallClosure) -> AnyPublisher<Response, GRPCStatus> {")
                    indent()
                    println("GUnaryCall(request: request, callOptions: callOptions, closure: callClosure).execute()")

                case .serverStreaming:
                    println("func \(methodFunctionName)(request: \(methodInputName), callOptions: CallOptions?, callClosure: CallClosure) -> AnyPublisher<Response, GRPCStatus> {")
                    indent()
                    println("GServerStreamingCall(request: request, callOptions: callOptions, closure: callClosure).execute()")

                case .clientStreaming:
                    println("func \(methodFunctionName)(request: AnyPublisher<\(methodInputName),Error> , callOptions: CallOptions?, callClosure: CallClosure) -> AnyPublisher<Response, GRPCStatus> {")
                    indent()
                    println("GClientStreamingCall(request: request, callOptions: callOptions, closure: callClosure).execute()")

                case .bidirectionalStreaming:
                    println("func \(methodFunctionName)(request: AnyPublisher<\(methodInputName),Error> , callOptions: CallOptions?, callClosure: CallClosure) -> AnyPublisher<Response, GRPCStatus> {")
                    indent()
                    println("GBidirectionalStreamingCall(request: request, callOptions: callOptions, closure: callClosure).execute()")
            }
        }
        outdent()
        println("}")
    }
}
