//
//  File.swift
//
//
//  Created by Tim Mewe on 24.01.20.
//

import Foundation

internal protocol ICommand {
    func run() throws
}

internal final class CommandLineTool: ICommand {
    private let command: Command
    private let protoPath: String
    private let destinationPath: String
    private let versionNumber: String?
    private let grebeGenerate: String?
    private let grpcGenerate: String?

    internal init(
        command: Command,
        protoPath: String,
        destinationPath: String,
        versionNumber: String?,
        grebeGenerate: String?,
        grpcGenerate: String?
    ) {
        self.command = command
        self.protoPath = protoPath
        self.destinationPath = destinationPath
        self.versionNumber = versionNumber
        self.grebeGenerate = grebeGenerate
        self.grpcGenerate = grpcGenerate
    }

    public func run() throws {
        switch command {
        case .setup:
            print("setup")
        case .generate:
            try GenerateCommand(protoPath: protoPath, destinationPath: destinationPath).run()
        }
    }
}
