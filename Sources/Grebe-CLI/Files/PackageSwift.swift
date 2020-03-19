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
    import PackageDescription

    let package = Package(
        name: "Grebe-Generated",
        products: [
            .library(name: "Grebe-Generated", targets: ["Grebe-Generated"])
        ],
        dependencies: [
            .package(url: "https://github.com/Apodini/Grebe", from: Version("\(version)"))
        ],
        targets: [
            .target(name: "Grebe-Generated", dependencies: ["Grebe"])
        ]
    )
    """
    }

    private let version: String

    init(version: String) {
        self.version = version
    }
}
