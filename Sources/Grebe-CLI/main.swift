//
//  main.swift
//
//
//  Created by Tim Mewe on 17.01.20.
//

// import SPMUtility
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
        var protoFilePath: String
        
        @Option(name: .shortAndLong, help: "Path of the generated Swift Package")
        var destinationFilePath: String
        
        @Option(name: .shortAndLong, help: "Path to a PATH directory")
        var pathDirectory: String?
        
        @Option(name: .shortAndLong, default: "1.0.0", help: "Version number of Grebe Code Generator")
        var versionNumber: String
        
        @Option(name: .shortAndLong, default: true, help: "Generate gRPC-Swift files")
        var grebeGenerate: Bool
        
        @Option(name: .shortAndLong, default: true, help: "Generate Grebe files")
        var grpcGenerate: Bool
        
        func run() {
            let arguments = Arguments(
                protoPath: protoFilePath,
                destinationPath: destinationFilePath,
                executablePath: pathDirectory ?? "/usr/local/bin",
                versionNumber: versionNumber,
                grebeGenerate: grebeGenerate,
                grpcGenerate: grpcGenerate
            )
            
            do {
                try GenerateCommand(arguments: arguments).run()
            } catch {
                print("An error occurred")
            }
        }
    }
    
    struct Setup: ParsableCommand {
        @Option(name: .shortAndLong, help: "Path to the temporary download directory")
        var downloadPath: String
        
        @Option(name: .shortAndLong, help: "Path to a PATH directory")
        var pathDirectory: String?
        
        func run() {
            do {
                try SetupCommand(
                    path: downloadPath,
                    envPath: pathDirectory ?? "/usr/local/bin"
                ).run()
            } catch {
                print("An error occurred")
            }
        }
    }
}

Grebe.main()
