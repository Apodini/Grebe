//
//  ProtoMethod.swift
//
//
//  Created by Tim Mewe on 16.01.20.
//

import Foundation

struct ProtoMethod {
    let name: String
    let request: String
    let response: String
    let stramingType: StreamType
    var callClosure: String { name.firstLowercased }

    enum StreamType {
        case unary
        case clientStreaming
        case serverStreaming
        case bidirectionalStreaming
    }

    init?(content: String) {
        var type = StreamType.unary
        // Format: rpc Send (stream EchoRequest) returns (stream EchoResponse);

        let removeRpcContent = content.replacingOccurrences(of: "rpc", with: "") // Remove rpc declaration
        // Format: Send (stream EchoRequest) returns (stream EchoResponse);

        let components = removeRpcContent.components(separatedBy: "(") // Seperates name, request & response
        // Format: Send  -  stream EchoRequest) returns    -  stream EchoResponse);

        guard components.count == 3 else { return nil } // We proceed only if we got all three

        // Parse Name
        self.name = components[0].replacingOccurrences(of: " ", with: "").firstLowercased // Remove spaces

        // Parse Request
        // Format: stream EchoRequest) returns
        var requestPart = components[1]
        if requestPart.contains("stream") {
            type = .clientStreaming
            requestPart = requestPart.replacingOccurrences(of: "stream ", with: "")
            // Format: EchoRequest) returns
        }
        guard let req = requestPart.components(separatedBy: ")").first else { return nil }
        self.request = req

        // Parse Response
        // Format: stream EchoResponse
        var responsePart = String(components[2].dropLast())
        // Format: stream EchoResponse)
        if responsePart.contains("stream") {
            type = (type == .clientStreaming) ? .bidirectionalStreaming : .serverStreaming
            responsePart = responsePart.replacingOccurrences(of: "stream ", with: "")
            // Format: EchoResponse
        }
        self.response = String(responsePart)
        self.stramingType = type

        print("Found Method: \(self.name) - request: \(self.request) - response: \(self.response) - type: \(type)")
    }
}

extension StringProtocol {
    var firstLowercased: String {
        return prefix(1).lowercased() + dropFirst()
    }
}
