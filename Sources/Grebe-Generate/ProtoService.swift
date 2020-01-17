//
//  File.swift
//
//
//  Created by Tim Mewe on 16.01.20.
//

import Foundation

struct ProtoService {
    let name: String
    var functions = [ProtoFunction]()
    
    init?(content: String) {
        let array = content.components(separatedBy: "{")
        
        // Parse Name
        guard let declaration = array.first else { return nil }
        let name = declaration.replacingOccurrences(of: "service", with: "")
        self.name = name.replacingOccurrences(of: " ", with: "")
        
        print("\nFound Service: \(name)")
        
        guard let functionsContent = array.last else { return }
        let functions = functionsContent.components(separatedBy: ";")
            .filter { !$0.isEmpty }
            .map { $0.dropFirst(2) }
        
        for function in functions {
            guard let f = ProtoFunction(content: String(function)) else { continue }
            self.functions.append(f)
        }
    }
}
