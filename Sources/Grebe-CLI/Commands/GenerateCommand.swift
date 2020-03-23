//
//  GenerateCommand.swift
//
//
//  Created by Tim Mewe on 24.01.20.
//

import Foundation

internal class GenerateCommand: IExecutableCommand {
    private var basePath: String { arguments.destinationPath + "/Grebe-Generated" }
    private var frameworkPath: String { basePath + "/.Grebe" }
    private var generatedDestinationPath: String { basePath + "/Sources/Grebe-Generated" }
    private let frameworkRemoteURL = "https://github.com/Apodini/Grebe.git"

    // MARK: - External Dependencies

    let arguments: Arguments

    // MARK: - Lifecycle

    internal init(arguments: Arguments) {
        self.arguments = arguments
    }

    // MARK: - IExecutableCommand

    func run() throws {
        try generateSwiftPackage()
        try generateCode()
        try buildDependencies()
    }

    // MARK: - Create Swift Package

    private func generateSwiftPackage() throws {
        print("Creating Swift Package...")
        try createDirectories()
        try createDefaultFiles()
    }

    private func createDirectories() throws {
        try FileManager.default.createDirectory(
            atPath: generatedDestinationPath,
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

        let gitignore = Gitignore()
        try gitignore.content.write(
            toFile: basePath + gitignore.name,
            atomically: true,
            encoding: .utf8
        )
    }

    // MARK: - Generate Code

    private func generateCode() throws {
        try loadBuildExecutable()
        try generateGRPC()
        try generateGrebe()
    }

    private func loadBuildExecutable() throws {
        // Clone Grebe-Framework Repo
        print("Cloning Grebe-Framework...")
        try shell("git", "clone", frameworkRemoteURL, frameworkPath, "-v", "--progress")

        // Build Grebe-Generate executable
        print("Building Grebe-Generate executable...")
        try shell(
            "swift", "build",
            "--verbose",
            "--product", "Grebe-Generate",
            "--package-path", frameworkPath,
            "-c", "release"
        )

        // Add executable to path
        try moveFile(
            from: "\(frameworkPath)/.build/release/Grebe-Generate",
            to: "\(arguments.executablePath)/protoc-gen-grebe-swift"
        )

        // Delete Grebe-Framework Repo
        try FileManager.default.removeItem(atPath: frameworkPath)
    }

    private func generateGRPC() throws {
        guard arguments.grpcGenerate else { return }

        var pathComponents = arguments.protoPath.components(separatedBy: "/")
        let protoName = pathComponents.removeLast()
        let protoPath = pathComponents.joined(separator: "/")

        print("Generating Swift protocol buffer files...")
        try shell(
            protoName, "--proto_path=\(protoPath)",
            "--grpc-swift_out=Visibility=Public:\(generatedDestinationPath)",
            "--swift_out=\(generatedDestinationPath)",
            "--plugin=protoc-gen-grpc-swift=\(arguments.executablePath)/protoc-gen-grpc-swift",
            "--plugin=protoc-gen-swift=\(arguments.executablePath)/protoc-gen-swift",
            "--swift_opt=Visibility=Public",
            launchPath: "\(arguments.executablePath)/protoc"
        )
    }

    private func generateGrebe() throws {
        guard arguments.grebeGenerate else { return }

        // Generate Grebe code
        print("Generating Grebe files...")
        try shell(
            "-p", arguments.protoPath,
            "-d", generatedDestinationPath,
            launchPath: "\(arguments.executablePath)/protoc-gen-grebe-swift"
        )
    }

    // MARK: - Build Dependencies

    private func buildDependencies() throws {
        print("Building package dependencies...")
        try shell(
            "swift", "build",
            "--verbose",
            "--package-path", basePath
        )
    }
}
