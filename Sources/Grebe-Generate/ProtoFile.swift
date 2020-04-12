//
//  ProtoFile.swift
//
//
//  Created by Tim Mewe on 16.01.20.
//

import Foundation

internal struct ProtoFile {
    let name: String
    var services = [ProtoService]()

    init(name: String, content: String) {
        print("New Proto File: \(name)")
        self.name = name
        services = content.split(separator: "\n") // Seperate each line
            .filter { !$0.starts(with: "//") } // Filter comments out
            .dropFirst() // Removes first line: syntax = "proto3";
            .joined(separator: "\n") // Merge to one string
            .filter { $0 != "\n" } // Filter line breaks out
            .split(separator: "}") // Seperates services and messages
            .filter { !$0.starts(with: "message") } // Filter messages out
            .map(String.init) // Map to String
            .map(ProtoService.init) // Create ProtoService
            .compactMap { $0 } // Filter nil objects
    }
}
