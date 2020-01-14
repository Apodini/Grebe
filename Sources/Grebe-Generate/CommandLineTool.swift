//
//  File.swift
//  
//
//  Created by Tim Mewe on 14.01.20.
//

import Foundation

public final class CommandLineTool {
    private let arguments: [String]
    
    public init(arguments: [String] = CommandLine.arguments) {
        self.arguments = arguments
    }
    
    public func run() throws {
        print("Hello World!")
    }
}
