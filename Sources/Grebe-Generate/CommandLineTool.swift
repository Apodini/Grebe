//
//  File.swift
//  
//
//  Created by Tim Mewe on 14.01.20.
//

import Foundation

public final class CommandLineTool {
    private let protoPath: String
    private let destinationPath: String
    
    public init(protoPath: String, destinationPath: String) {
        self.protoPath = protoPath
        self.destinationPath = destinationPath
    }
    
    public func run() throws {
        print("Hello World!")
    }
}
