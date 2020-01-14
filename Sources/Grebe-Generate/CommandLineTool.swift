//
//  File.swift
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
        print("Hello World!")
        let protoString = try String(contentsOfFile: protoPath)
        var response = Google_Protobuf_Compiler_CodeGeneratorResponse()
        let protoDesriptor = try Google_Protobuf_FileDescriptorProto(textFormatString: protoString)
        let descriptorSet = DescriptorSet(protos: [protoDesriptor])
        
        for fileDesriptor in descriptorSet.files {
            guard !fileDesriptor.services.isEmpty else { return }
            
            let fileName = outputFileName(fileDescriptor: fileDesriptor)
            let generator = Generator(fileDesriptor)
            
            var file = Google_Protobuf_Compiler_CodeGeneratorResponse.File()
            file.name = fileName
            file.content = generator.code
            response.file.append(file)
        }
        
        let serializedResponse = try response.serializedData()
        Stdout.write(bytes: serializedResponse)
    }
    
    private func outputFileName(fileDescriptor: FileDescriptor) -> String {
        let ext = "." + "grebe" + ".swift"
        let pathParts = splitPath(pathname: fileDescriptor.name)
        return pathParts.base + ext
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
