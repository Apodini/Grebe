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
    private let version: String

    // MARK: - Lifecycle

    internal init(protoPath: String, destinationPath: String, version: String) {
        self.protoPath = protoPath
        self.destinationPath = destinationPath
        self.version = version
    }

    // MARK: - ICommand

    func run() throws {
        try createDirectories()
        try createDefaultFiles()
    }
    
    // MARK: - Private Functions

    private func createDirectories() throws {
        try FileManager.default.createDirectory(
            atPath: basePath + "/Sources/Grebe",
            withIntermediateDirectories: true
        )
    }

    private func createDefaultFiles() throws {
        let readme = Readme()
        try readme.content.write(
            toFile: basePath + readme.name,
            atomically: true,
            encoding: .utf8
        )

        let package = PackageSwift(version: version)
        try package.content.write(
            toFile: basePath + package.name,
            atomically: true,
            encoding: .utf8
        )
    }
}
