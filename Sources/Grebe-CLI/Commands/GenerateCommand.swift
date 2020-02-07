//
//  GenerateCommand.swift
//
//
//  Created by Tim Mewe on 24.01.20.
//

import Foundation

internal class GenerateCommand: IExecutableCommand {
    private var basePath: String { arguments.destinationPath + "/Grebe" }
    private var frameworkPath: String { basePath + "/.Grebe-Framework" }
    private var generatedDestinationPath: String { basePath + "/Sources/Grebe" }
    private let envPath = "/usr/local/bin"
    private let frameworkRemoteURL = "https://ge24zaz:Qojzon-jatxu8-saxvaq@bitbucket.ase.in.tum.de/scm/batimmewe/grebe-framework.git"

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
    }

    // MARK: - Create Swift Package

    private func generateSwiftPackage() throws {
        try createDirectories()
        try createDefaultFiles()
    }

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
            to: "\(envPath)/protoc-gen-grebe-swift"
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
            "--grpc-swift_out=\(generatedDestinationPath)",
            "--swift_out=\(generatedDestinationPath)",
            "--plugin=protoc-gen-grpc-swift=\(envPath)/protoc-gen-grpc-swift",
            "--plugin=protoc-gen-swift=\(envPath)/protoc-gen-swift",
            launchPath: "\(envPath)/protoc"
        )
    }

    private func generateGrebe() throws {
        guard arguments.grebeGenerate else { return }

        // Generate Grebe code
        print("Generating Grebe files...")
        try shell(
            "-p", arguments.protoPath,
            "-d", generatedDestinationPath,
            launchPath: "\(envPath)/grebe-generate"
        )
    }
}
