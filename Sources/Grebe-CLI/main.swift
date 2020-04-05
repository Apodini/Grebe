//
//  main.swift
//
//
//  Created by Tim Mewe on 17.01.20.
//

import ArgumentParser
import Foundation

struct Grebe: ParsableCommand {
    static var configuration = CommandConfiguration(
        subcommands: [Generate.self, Setup.self],
        defaultSubcommand: Generate.self
    )
}

extension Grebe {
    struct Generate: ParsableCommand {
        @Option(name: .shortAndLong, help: "Path to the proto file")
        var proto: String
        
        @Option(name: .shortAndLong, help: "Path of the generated Swift Package")
        var destination: String
        
        @Option(name: .shortAndLong, help: "Path to a PATH directory")
        var pathDirectory: String?
        
        @Option(name: .shortAndLong, default: "0.0.3", help: "Version number of Grebe Code Generator")
        var version: String
        
        @Option(name: .shortAndLong, default: true, help: "Generate gRPC-Swift files")
        var grebeGenerate: Bool
        
        @Option(name: .shortAndLong, default: true, help: "Generate Grebe files")
        var swiftGrpcGenerate: Bool
        
        func run() {
            let arguments = Arguments(
                protoPath: proto,
                destinationPath: destination,
                executablePath: pathDirectory ?? "/usr/local/bin",
                versionNumber: version,
                grebeGenerate: grebeGenerate,
                grpcGenerate: swiftGrpcGenerate
            )
            
            do {
                try GenerateCommand(arguments: arguments).run()
            } catch {
                print("An error occurred")
            }
        }
    }
    
    struct Setup: ParsableCommand {
        @Option(name: .shortAndLong, help: "Path to a PATH directory")
        var pathDirectory: String?
        
        func run() {
            do {
                try SetupCommand(
                    envPath: pathDirectory ?? "/usr/local/bin"
                ).run()
            } catch {
                print("An error occurred")
            }
        }
    }
}

Grebe.main()
