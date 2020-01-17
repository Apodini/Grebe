//
//  CommandLineTool.swift
//
//
//  Created by Tim Mewe on 14.01.20.
//

import Foundation
import SwiftProtobuf
import SwiftProtobufPluginLibrary

public final class CommandLineTool {
    private let protoPath: String
    private let destinationPath: String
    
    public init(protoPath: String, destinationPath: String) {
        self.protoPath = protoPath
        self.destinationPath = destinationPath
    }
    
    public func run() throws {
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
    private func splitPath(pathname: String) -> (dir: String, base: String, suffix: String) {
        var dir = ""
        var base = ""
        var suffix = ""
        #if swift(>=3.2)
            let pathnameChars = pathname
        #else
            let pathnameChars = pathname.characters
        #endif
        for c in pathnameChars {
            if c == "/" {
                dir += base + suffix + String(c)
                base = ""
                suffix = ""
            } else if c == "." {
                base += suffix
                suffix = String(c)
            } else {
                suffix += String(c)
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
