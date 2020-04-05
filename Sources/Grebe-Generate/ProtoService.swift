//
//  ProtoService.swift
//
//
//  Created by Tim Mewe on 16.01.20.
//

import Foundation

struct ProtoService {
    let name: String
    var methods = [ProtoMethod]()

    init?(content: String) {
        let array = content.components(separatedBy: "{") // Seperate service name and methods

        // Parse Name
        guard let declaration = array.first else { return nil }
        self.name = declaration
            .replacingOccurrences(of: "service", with: "") // Remove the service declaration
            .replacingOccurrences(of: " ", with: "") // Remove spaces

        print("\nFound Service: \(self.name)")

        // Parse functions
        guard let methodsContent = array.last else { return }
        self.methods = methodsContent
            .split(separator: ";") // Seperates each method
            .map(String.init) // Map to String
            .map(ProtoMethod.init) // Create ProtoMethod
            .compactMap { $0 } // Filter nil objects
    }
}
