//
//  File.swift
//
//
//  Created by Tim Mewe on 14.01.20.
//

import Foundation
import Logging
import SPMUtility

private let parser = ArgumentParser(usage: "-p <path>", overview: "Grebe Code Generator")

// <options>
private let protoFilePath = parser.add(
    option: "--proto",
    shortName: "-p",
    kind: String.self,
    usage: "The path to the proto file",
    completion: .filename
)

private let destinationPath = parser.add(
    option: "--destination",
    shortName: "-d",
    kind: String.self,
    usage: "The path of the generated Swift file",
    completion: .filename
)

let tool = CommandLineTool()
do {
    try tool.run()
} catch {
    print("Whoops! An error occurred: \(error)")
}
