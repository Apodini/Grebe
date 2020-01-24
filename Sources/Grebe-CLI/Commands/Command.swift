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
