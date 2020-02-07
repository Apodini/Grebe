//
//  Command.swift
//
//
//  Created by Tim Mewe on 24.01.20.
//

import Foundation

internal protocol IExecutableCommand {
    func run() throws
}

extension IExecutableCommand {
    internal func moveFile(from: String, to: String) throws {
        if FileManager.default.fileExists(atPath: to) {
            try FileManager.default.removeItem(atPath: to)
        }
        try FileManager.default.moveItem(atPath: from, toPath: to)
    }
}

internal func shell(_ args: String..., launchPath: String = "/usr/bin/env") throws {
    let process = Process()
    process.arguments = args
    process.executableURL = URL(fileURLWithPath: launchPath)

    let outputPipe = Pipe()
    let errorPipe = Pipe()
    process.standardOutput = outputPipe
    process.standardError = errorPipe

    try process.run()

    let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
    let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
    print(String(decoding: outputData, as: UTF8.self))
    print(String(decoding: errorData, as: UTF8.self))

    process.waitUntilExit()
}

internal enum Command: String {
    case setup
    case generate
}

internal enum CLIError: Error {
    case noCommand(expected: String)

    var localizedDescription: String {
        switch self {
        case .noCommand:
            return "Whoops! Please enter a valid command!"
        }
    }
}

extension CLIError: LocalizedError {
    public var errorDescription: String? {
        return description
    }
}

extension CLIError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .noCommand(let expected):
            return "Expected commands: \(expected)"
        }
    }
}