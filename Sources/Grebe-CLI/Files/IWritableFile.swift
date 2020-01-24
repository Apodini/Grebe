//
//  IWritableFile.swift
//  
//
//  Created by Tim Mewe on 24.01.20.
//

import Foundation

internal protocol IWritableFile {
    var name: String { get }
    var content: String { get }
}
