//
//  File.swift
//
//
//  Created by Tim Mewe on 24.01.20.
//

import Foundation

internal class GenerateCommand: IExecutableCommand {
    private var basePath: String { arguments.destinationPath + "/Grebe" }
    private var frameworkPath: String { basePath + "/Grebe-Framework" }
    private var generatedDestinationPath: String { basePath + "/Sources/Grebe" }
    private let frameworkRemoteURL = "https://ge24zaz:Qojzon-jatxu8-saxvaq@bitbucket.ase.in.tum.de/scm/batimmewe/grebe-framework.git"

    // MARK: - External Dependencies

    let arguments: Arguments

    // MARK: - Lifecycle

    internal init(arguments: Arguments) {
        self.arguments = arguments
    }

    // MARK: - ICommand

    func run() throws {
        try createDirectories()
        try createDefaultFiles()
        try generateCode()
    }

    // MARK: - Private Functions

    // MARK: - Create Swift Package

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

        let package = PackageSwift(version: arguments.versionNumber)
        try package.content.write(
            toFile: basePath + package.name,
            atomically: true,
            encoding: .utf8
        )
    }

    // MARK: - Generate Code

    private func generateCode() throws {
//        try loadBuildExecutable()
        try generateGRPC()
//        try generateGrebe()
    }

    private func loadBuildExecutable() throws {
        // Clone Grebe-Framework Repo
        try shell("git", "clone", frameworkRemoteURL, frameworkPath)

        // Build Grebe-Generate executable
        try shell(
            "swift", "build",
            "--product", "Grebe-Generate",
            "--package-path", frameworkPath,
            "-c", "release"
        )

        // Add executable to path
        try shell(
            "cp",
            "-f", "\(frameworkPath)/.build/release/Grebe-Generate",
            "/usr/local/bin/grebe-generate"
        )

        // Delete Grebe-Framework Repo
        try FileManager.default.removeItem(atPath: frameworkPath)
    }

    private func generateGRPC() throws {
        guard arguments.grpcGenerate else { return }
        
        var pathComponents = arguments.protoPath.components(separatedBy: "/")
        let protoName = pathComponents.removeLast()
        let protoPath = pathComponents.joined(separator: "/")

        try shell(
            protoName, "--proto_path=\(protoPath)",
            "--grpc-swift_out=\(generatedDestinationPath)",
            "--swift_out=\(generatedDestinationPath)",
            "--plugin=protoc-gen-grpc-swift=/usr/local/bin/protoc-gen-grpc-swift",
            "--plugin=protoc-gen-swift=/usr/local/bin/protoc-gen-swift",
            launchPath: "/usr/local/bin/protoc"
        )
    }

    private func generateGrebe() throws {
        guard arguments.grebeGenerate else { return }

        // Generate Grebe code
        try shell(
            "-p", arguments.protoPath,
            "-d", generatedDestinationPath,
            launchPath: "/usr/local/bin/grebe-generate"
        )
    }
}
