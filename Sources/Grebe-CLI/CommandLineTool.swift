//
//  File.swift
//
//
//  Created by Tim Mewe on 24.01.20.
//

import Foundation

internal final class CommandLineTool: IExecutableCommand {
    // MARK: - External Dependencies

    let arguments: Arguments

    // MARK: - Lifecycle

    internal init(arguments: Arguments) {
        self.arguments = arguments
    }

    // MARK: - ICommand

    public func run() throws {
        switch arguments.command {
        case .setup:
            print("setup")
        case .generate:
            try GenerateCommand(arguments: arguments).run()
        }
    }
}
