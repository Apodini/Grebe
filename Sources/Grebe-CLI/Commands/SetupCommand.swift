//
//  SetupCommand.swift
//
//
//  Created by Tim Mewe on 25.01.20.
//

import Foundation

internal class SetupCommand: IExecutableCommand {
    private let grpcURL = "https://github.com/grpc/grpc-swift/"
    private var repoPath: String { path + "grpc-swift" }
    
    // MARK: - External Dependencies
    
    private let path: String
    private let envPath: String
    
    // MARK: - Lifecycle
    
    init(path: String, envPath: String) {
        self.path = path
        self.envPath = envPath
    }
    
    // MARK: - IExecutableCommand
    
    func run() throws {
        print("""
        We use Homebrew to install Grebe. Please make sure you have Homebrew installed.
        If not you can download it here: https://brew.sh
        """)
        // Install protobuf via brew
        try shell("reinstall", "protobuf", launchPath: "\(envPath)/brew")

        // Install swift protobuf via brew
        try shell("reinstall", "swift-protobuf", launchPath: "\(envPath)/brew")

        // Checkout grpc-swift repo
        try shell("git", "clone", "--single-branch", "--branch", "nio", grpcURL, repoPath, "-v", "--progress")

        // Make plugins
        try shell("make", "plugins", "--directory", repoPath)

        // Move plugins to path
        try moveFile(from: repoPath + "/protoc-gen-grpc-swift", to: envPath + "/protoc-gen-grpc-swift")
        try moveFile(from: repoPath + "/protoc-gen-swift", to: envPath + "/protoc-gen-swift")

        // Delete grpc-swift repo
        try FileManager.default.removeItem(atPath: repoPath)
    }
}
