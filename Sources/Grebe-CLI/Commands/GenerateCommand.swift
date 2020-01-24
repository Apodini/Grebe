//
//  File.swift
//
//
//  Created by Tim Mewe on 24.01.20.
//

import Foundation

internal class GenerateCommand: IExecutableCommand {
    private var basePath: String { destinationPath + "/Grebe" }

    // MARK: - External Dependencies

    private let protoPath: String
    private let destinationPath: String

    // MARK: - Lifecycle

    internal init(protoPath: String, destinationPath: String) {
        self.protoPath = protoPath
        self.destinationPath = destinationPath
    }

    // MARK: - ICommand

    func run() throws {
        try FileManager.default.createDirectory(
            atPath: basePath + "/Sources/Grebe",
            withIntermediateDirectories: true
        )

        let readme = Readme()
        try readme.content.write(
            toFile: basePath + readme.name,
            atomically: true,
            encoding: .utf8
        )
        
        let package = PackageSwift()
        try package.content.write(
            toFile: basePath + package.name,
            atomically: true,
            encoding: .utf8
        )
    }
}
