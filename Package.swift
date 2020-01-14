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
        .executable(name: "Grebe-Generate", targets: ["Grebe-Generate"])
    ],
    dependencies: [
        .package(url: "https://github.com/grpc/grpc-swift.git", from: "1.0.0-alpha.7"),
    ],
    targets: [
        .target(name: "Grebe-Framework", dependencies: ["GRPC"]),
        .target(name: "Grebe-Generate", dependencies: ["Grebe-Framework"]),
        .testTarget(name: "Grebe-FrameworkTests", dependencies: ["Grebe-Framework"]),
    ]
)
