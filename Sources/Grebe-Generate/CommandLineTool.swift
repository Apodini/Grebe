//
//  CommandLineTool.swift
//
//
//  Created by Tim Mewe on 14.01.20.
//

import Foundation

internal final class CommandLineTool {
    private let protoPath: String
    private let destinationPath: String

    internal init(protoPath: String, destinationPath: String) {
        self.protoPath = protoPath
        self.destinationPath = destinationPath
    }

    internal func run() throws {
        let protoName = splitPath(pathname: protoPath).base
        let protoString = try String(contentsOfFile: protoPath)
        let protoFile = ProtoFile(name: protoName, content: protoString)
        let generator = Generator(protoFile)

        try writeFile(name: protoName, content: generator.code)
    }

    private func writeFile(name: String, content: String) throws {
        let outputFile = outputFileName(name: name, path: destinationPath)
        try content.write(
            toFile: outputFile,
            atomically: true,
            encoding: .utf8
        )
    }

    private func outputFileName(name: String, path: String) -> String {
        let ext = name + "." + "grebe" + ".swift"
        return path + "/" + ext
    }

    // from apple/swift-protobuf/Sources/protoc-gen-swift/StringUtils.swift
    // swiftlint:disable large_tuple
    private func splitPath(pathname: String) -> (dir: String, base: String, suffix: String) {
        var dir = ""
        var base = ""
        var suffix = ""
        #if swift(>=3.2)
            let pathnameChars = pathname
        #else
            let pathnameChars = pathname.characters
        #endif
        for char in pathnameChars {
            if char == "/" {
                dir += base + suffix + String(char)
                base = ""
                suffix = ""
            } else if char == "." {
                base += suffix
                suffix = String(char)
            } else {
                suffix += String(char)
            }
        }
        #if swift(>=3.2)
            let validSuffix = suffix.isEmpty || suffix.first == "."
        #else
            let validSuffix = suffix.isEmpty || suffix.characters.first == "."
        #endif
        if !validSuffix {
            base += suffix
            suffix = ""
        }
        return (dir: dir, base: base, suffix: suffix)
    }
}
