// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Grebe",
    platforms: [
        .macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6),
    ],
    products: [
        .library(name: "Grebe-Framework", targets: ["Grebe-Framework"]),
        .executable(name: "Grebe-Generate", targets: ["Grebe-Generate"]),
        .executable(name: "grebe", targets: ["Grebe-CLI"])
    ],
    dependencies: [
        .package(name: "GRPC",
                 url: "https://github.com/grpc/grpc-swift.git",
                 .exact("1.0.0-alpha.8")
        ),
        .package(name: "SwiftProtobuf",
                 url: "https://github.com/apple/swift-protobuf.git",
                 from: "1.7.0"
        ),
        .package(name: "swift-argument-parser",
                 url: "https://github.com/apple/swift-argument-parser",
                 .upToNextMinor(from: "0.0.1")
        )
    ],
    targets: [
        .target(name: "Grebe-Framework", dependencies: [.product(name: "GRPC", package: "GRPC")]),
        .target(
            name: "Grebe-Generate",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "SwiftProtobufPluginLibrary", package: "SwiftProtobuf")
            ]
        ),
        .target(
            name: "Grebe-CLI",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        ),
        .testTarget(name: "Grebe-FrameworkTests", dependencies: ["Grebe-Framework"])
    ]
)
