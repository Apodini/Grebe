//
//  main.swift
//
//
//  Created by Tim Mewe on 14.01.20.
//

import Foundation
import Logging
import SPMUtility

private let parser = ArgumentParser(usage: "-p <path>", overview: "Grebe Code Generator")

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

// The first argument specifies the path of the executable file
private let currentPath = CommandLine.arguments.removeFirst()
do {
    let result = try parser.parse(CommandLine.arguments)
    guard let protoPath = result.get(protoFilePath) else {
        throw ArgumentParserError.expectedValue(option: "--proto")
    }
    let destinationPath = result.get(destinationFilePath) ?? currentPath

    let tool = CommandLineTool(protoPath: protoPath, destinationPath: destinationPath)
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

enum FileNaming: String {
    case FullPath
    case PathToUnderscores
    case DropPath
}
