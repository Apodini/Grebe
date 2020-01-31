//
//  SetupCommand.swift
//
//
//  Created by Tim Mewe on 25.01.20.
//

import Foundation

internal class SetupCommand: IExecutableCommand {
    private let grpcURL = "https://github.com/grpc/grpc-swift/"
    private var repoPath: String { path + "/grpc-swift" }
    private let envPath = "/usr/local/bin"
    
    // MARK: - External Dependencies
    
    private let version: String
    private let path: String
    
    // MARK: - Lifecycle
    
    init(version: String, path: String) {
        self.version = version
        self.path = path
    }
    
    // MARK: - ICommand
    
    func run() throws {
        // Install protobuf via brew
        try shell("reinstall", "protobuf", launchPath: "\(envPath)/brew")
        
        // Install swift protobuf via brew
        try shell("reinstall", "swift-protobuf", launchPath: "\(envPath)/brew")
        
        // Checkout grpc-swift repo
        try shell("git", "clone", "--single-branch", "--branch", "nio", grpcURL, repoPath)
        
        // Make plugins
        try shell("make", "plugins", "--directory", repoPath)
        
        // Move plugins to path
        try moveFile(from: repoPath + "/protoc-gen-grpc-swift", to: envPath + "/protoc-gen-grpc-swift")
        try moveFile(from: repoPath + "/protoc-gen-swift", to: envPath + "/protoc-gen-swift")
        
        // Delete grpc-swift repo
        try FileManager.default.removeItem(atPath: repoPath)
    }
    
    // MARK: - Private Functions
}
