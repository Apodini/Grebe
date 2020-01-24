// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Grebe-Framework",
    platforms: [
        .macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6),
    ],
    products: [
        .library(name: "Grebe-Framework", targets: ["Grebe-Framework"]),
        .executable(name: "Grebe-Generate", targets: ["Grebe-Generate"]),
        .executable(name: "Grebe-CLI", targets: ["Grebe-CLI"])
    ],
    dependencies: [
        .package(url: "https://github.com/grpc/grpc-swift.git", from: "1.0.0-alpha.7"),
        .package(url: "https://github.com/apple/swift-package-manager.git", from: "0.5.0"),
        .package(url: "https://github.com/apple/swift-protobuf.git", from: "1.7.0"),
    ],
    targets: [
        .target(name: "Grebe-Framework", dependencies: ["GRPC"]),
        .target(name: "Grebe-Generate", dependencies: [
            "Grebe-Framework",
            "SPMUtility",
            "SwiftProtobufPluginLibrary"]),
        .target(name: "Grebe-CLI", dependencies: ["SPMUtility"]),
        .testTarget(name: "Grebe-FrameworkTests", dependencies: ["Grebe-Framework"]),
    ]
)
