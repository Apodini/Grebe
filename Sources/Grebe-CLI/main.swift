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

private let executableFilePath = parser.add(
    option: "--executable",
    shortName: "-e",
    kind: String.self,
    usage: "The path of the generated executables",
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
    kind: Bool.self,
    usage: "Generate only Grebe files"
)

private let grpcGenerate = parser.add(
    option: "--swiftgrpc",
    shortName: "-s",
    kind: Bool.self,
    usage: "Gv"
)

// The first argument specifies the path of the executable file
private let currentPath = CommandLine.arguments.removeFirst()
do {
    guard !CommandLine.arguments.isEmpty,
        let command = Command(rawValue: CommandLine.arguments.removeFirst()) else {
        throw CLIError.noCommand(expected: "setup or generate")
    }

    let result = try parser.parse(CommandLine.arguments)
    let executablePath = result.get(executableFilePath) ?? "/usr/local/bin"

    switch command {
    case .setup:
        try SetupCommand(path: currentPath, envPath: executablePath).run()
    case .generate:
        guard let protoPath = result.get(protoFilePath) else {
            print("No proto file found!")
            throw ArgumentParserError.expectedValue(option: "--proto")
        }
        let destinationPath = result.get(destinationFilePath) ?? currentPath
        let version = result.get(versionNumber)
        let grebe = result.get(grebeGenerate)
        let grpc = result.get(grpcGenerate)

        let generateAll = (grebe == nil && grpc == nil)

        let arguments = Arguments(
            protoPath: protoPath,
            destinationPath: destinationPath,
            executablePath: executablePath,
            versionNumber: version ?? "1.0.0",
            grebeGenerate: grebe != nil ? true : generateAll,
            grpcGenerate: grpc != nil ? true : generateAll
        )

        try GenerateCommand(arguments: arguments).run()
    }

} catch let error as ArgumentParserError {
    print(error.description)
} catch {
    print(error.localizedDescription)
}
