//
//  File.swift
//  
//
//  Created by Tim Mewe on 24.01.20.
//

import Foundation

internal class GenerateCommand: ICommand {
    private let protoPath: String
    private let destinationPath: String
    
    internal init(protoPath: String, destinationPath: String) {
        self.protoPath = protoPath
        self.destinationPath = destinationPath
    }
    
    func run() throws {
        
    }
}
