//
//  main.swift
//
//
//  Created by Tim Mewe on 17.01.20.
//

import Foundation
import SPMUtility

private let parser = ArgumentParser(usage: "-p <path>", overview: "Grebe Command Line Interface")

// <options>
private let protoFilePath = parser.add(
    option: "--proto",
    shortName: "-p",
    kind: String.self,
    usage: "The path to the proto file",
    completion: .filename
)

private let destinationFilePath = parser.add(
    option: "--destination",
    shortName: "-d",
    kind: String.self,
    usage: "The path of the generated Swift file",
    completion: .filename
)

private let versionNumber = parser.add(
    option: "--version",
    shortName: "-v",
    kind: String.self,
    usage: "The version number of Grebe"
)

private let grebeGenerate = parser.add(
    option: "--grebe",
    shortName: "-g",
    kind: String.self,
    usage: "Generate only Grebe files"
)

private let grpcGenerate = parser.add(
    option: "--swiftgrpc",
    shortName: "-s",
    kind: String.self,
    usage: "Generate only gRPC-Swift files"
)

// The first argument specifies the path of the executable file
private let currentPath = CommandLine.arguments.removeFirst()
do {
    guard !CommandLine.arguments.isEmpty,
        let command = Command(rawValue: CommandLine.arguments.removeFirst()) else {
        throw CLIError.noCommand(expected: "setup or generate")
    }

    let result = try parser.parse(CommandLine.arguments)
    guard let protoPath = result.get(protoFilePath) else {
        throw ArgumentParserError.expectedValue(option: "--proto")
    }
    let destinationPath = result.get(destinationFilePath) ?? currentPath
    let version = result.get(versionNumber)
    let grebe = result.get(grebeGenerate)
    let grpc = result.get(grpcGenerate)

    let arguments = Arguments(
        command: command,
        protoPath: protoPath,
        destinationPath: destinationPath,
        versionNumber: version ?? "1.0", //TODO: Get latest version number
        grebeGenerate: grebe != nil ? true : false,
        grpcGenerate: grpc != nil ? true : false
    )

    let tool = CommandLineTool(arguments: arguments)
    do {
        try tool.run()
    } catch {
        print("Whoops! An error occurred: \(error)")
    }

} catch let error as ArgumentParserError {
    print(error.description)
} catch {
    print(error.localizedDescription)
}

internal func shell(_ args: String..., launchPath: String = "/usr/bin/env") throws {
    let process = Process()
    process.arguments = args
    process.launchPath = launchPath
    
    let pipe = Pipe()
    process.standardOutput = pipe
    process.launch()
    process.waitUntilExit()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output: String = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
    print(output)
}
