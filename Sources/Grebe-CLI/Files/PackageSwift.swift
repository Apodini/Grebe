//
//  PackageSwift.swift
//
//
//  Created by Tim Mewe on 24.01.20.
//

import Foundation

internal struct PackageSwift: IWritableFile {
    let name: String = "/Package.swift"

    var content: String { """
    // swift-tools-version:5.1
    // The swift-tools-version declares the minimum version of Swift required to build this package.

    import PackageDescription

    let package = Package(
        name: "Grebe",
        products: [
            // Products define the executables and libraries produced by a package, and make them visible to other packages.
            .library(
                name: "Grebe",
                targets: ["Grebe"])
        ],
        dependencies: [
            // Dependencies declare other packages that this package depends on.
            .package(url: "https://github.com/timmewe/grebe-framework.git", from: "\(version)")
        ],
        targets: [
            // Targets are the basic building blocks of a package. A target can define a module or a test suite.
            // Targets can depend on other targets in this package, and on products in packages which this package depends on.
            .target(
                name: "Grebe",
                dependencies: ["Grebe-Framework"])
        ]
    )
    """
    }

    private let version: String

    init(version: String) {
        self.version = version
    }
}
