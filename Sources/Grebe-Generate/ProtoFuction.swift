//
//  File.swift
//  
//
//  Created by Tim Mewe on 16.01.20.
//

import Foundation

struct ProtoFunction {
    
    let name: String
    let request: String
    let response: String
    let stramingType: StreamType
    
    init?(content: String) {
        var type = StreamType.unary
        //Format: rpc Send (stream EchoRequest) returns (stream EchoResponse);
        
        let a = content.replacingOccurrences(of: "rpc ", with: "")
        //Format: Send (stream EchoRequest) returns (stream EchoResponse);
        
        let components = a.components(separatedBy: "(")
        //Format: Send
        
        guard components.count == 3 else { return nil }
        
        
        //Parse Name
        self.name = String(components[0].dropLast())
        
        
        //Parse Request
         //Format: stream EchoRequest) returns
        var requestPart = components[1]
        if requestPart.contains("stream") {
            type = .clientStreaming
            requestPart = requestPart.replacingOccurrences(of: "stream ", with: "")
            //Format: EchoRequest) returns
        }
        guard let req = requestPart.components(separatedBy: ")").first else { return nil }
        self.request = req
        
        
        //Parse Response
        //Format: stream EchoResponse
        var responsePart = String(components[2].dropLast())
        //Format: stream EchoResponse)
        if responsePart.contains("stream") {
            type = (type == .clientStreaming) ? . bidirectionalStreaming : .serverStreaming
            responsePart = responsePart.replacingOccurrences(of: "stream ", with: "")
            //Format: EchoResponse
        }
        self.response = String(responsePart)
        self.stramingType = type
        
        print("Found Method: \(name) - request: \(request) - response: \(response) - type: \(type)")
    }
    
    enum StreamType {
        case unary
        case clientStreaming
        case serverStreaming
        case bidirectionalStreaming
    }
}
