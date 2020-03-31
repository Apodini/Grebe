//
//  main.swift
//
//
//  Created by Tim Mewe on 14.01.20.
//

import ArgumentParser
import Foundation

struct Generate: ParsableCommand {
    @Option(name: .shortAndLong, help: "Path to the proto file")
    var protoFilePath: String
    
    @Option(name: .shortAndLong, help: "Path to the generated Swift file")
    var destinationFilePath: String
    
    func run() {
        let tool = CommandLineTool(protoPath: protoFilePath, destinationPath: destinationFilePath)
        do {
            try tool.run()
        } catch {
            print("Whoops! An error occurred: \(error)")
        }
    }
}

Generate.main()
