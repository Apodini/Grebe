//
//  File.swift
//
//
//  Created by Tim Mewe on 16.01.20.
//

import Foundation

struct ProtoFile {
    
    let name: String
    var services = [ProtoService]()
    
    init(name: String, content: String) {
        print("New Proto File")
        self.name = name
        let linesArray = content.components(separatedBy: "\n")
            .filter { !$0.starts(with: "//") }
            .filter { !$0.isEmpty }
            .dropFirst()
        let noFirstLine = linesArray.joined(separator: "\n")
        let noLineBreaks = noFirstLine.filter { $0 != "\n" }
        let contentArray = noLineBreaks.components(separatedBy: "}").filter { $0 != "" }
        let services = contentArray.filter { !$0.starts(with: "message") }
        
        print("Found services:")
        print(services)
        
        for service in services {
            guard let pService = ProtoService(content: service) else { continue }
            self.services.append(pService)
        }
        print(self.services)
    }
}
