//
//  Echo+Init.swift
//  
//
//  Created by Tim Mewe on 10.01.20.
//

import Foundation

extension EchoRequest {
    init(id: Int) {
        self.id = Int32(id)
    }
}

extension EchoResponse {
    init(id: Int) {
        self.id = Int32(id)
    }
}
