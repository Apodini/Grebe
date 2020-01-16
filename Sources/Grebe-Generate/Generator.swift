//
//  File.swift
//
//
//  Created by Tim Mewe on 14.01.20.
//

import SwiftProtobuf
import SwiftProtobufPluginLibrary

class Generator {
    private var printer: CodePrinter
    internal var file: ProtoFile
    internal var service: ProtoService! // context during generation
    internal var method: ProtoFunction! // context during generation

    init(_ file: ProtoFile) {
        self.file = file
        printer = CodePrinter()

        printMain()
    }

    public var code: String {
        return printer.content
    }

    private func printMain() {
        printer.print("""
        //
        // DO NOT EDIT.
        //
        // Generated by the protocol buffer compiler.
        // Source: \(file.name)
        //
        """)

        let moduleNames = [
            "Grebe_Framework"
        ]

        for moduleName in moduleNames.sorted() {
            println("import \(moduleName)")
        }

        for service in file.services {
            self.service = service
            printGrebe()
        }
    }

    internal func println(_ text: String = "") {
        printer.print(text)
        printer.print("\n")
    }

    internal func indent() {
        printer.indent()
    }

    internal func outdent() {
        printer.outdent()
    }
}
