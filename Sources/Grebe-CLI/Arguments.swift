//
//  Arguments.swift
//  
//
//  Created by Tim Mewe on 24.01.20.
//

import Foundation

struct Arguments {
    let command: Command
    let protoPath: String
    let destinationPath: String
    let versionNumber: String
    let grebeGenerate: Bool
    let grpcGenerate: Bool
}
