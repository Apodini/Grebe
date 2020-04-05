//
//  SetupCommand.swift
//
//
//  Created by Tim Mewe on 25.01.20.
//

import Foundation

internal class SetupCommand: IExecutableCommand {
    private let grpcURL = "https://github.com/grpc/grpc-swift/"
    private var repoPath: String { envPath + "/grpc-swift" }
    
    // MARK: - External Dependencies
    
    private let envPath: String
    
    // MARK: - Lifecycle
    
    init(envPath: String) {
        self.envPath = envPath
    }
    
    // MARK: - IExecutableCommand
    
    func run() throws {
        print("""
        We use Homebrew to install Grebe. Please make sure you have Homebrew installed.
        If not you can download it here: https://brew.sh
        """)
        // Install protobuf via brew
        print("Installing Protobuf...")
        try shell("reinstall", "protobuf", launchPath: "\(envPath)/brew")

        // Install swift protobuf via brew
        print("Installing Swift Protobuf...")
        try shell("reinstall", "swift-protobuf", launchPath: "\(envPath)/brew")

        // Checkout grpc-swift repo
        print("Making gRPC-Swift plugins")
        try shell("git", "clone", "--single-branch", "--branch", "1.0.0-alpha.8", grpcURL, repoPath, "-v", "--progress")

        // Make plugins
        try shell("make", "plugins", "--directory", repoPath)

        // Move plugins to path
        try moveFile(from: repoPath + "/protoc-gen-grpc-swift", to: envPath + "/protoc-gen-grpc-swift")
        try moveFile(from: repoPath + "/protoc-gen-swift", to: envPath + "/protoc-gen-swift")

        // Delete grpc-swift repo
        try FileManager.default.removeItem(atPath: repoPath)
    }
}
