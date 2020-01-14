//
//  File.swift
//
//
//  Created by Tim Mewe on 14.01.20.
//

import Foundation

#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif

private let _write = write

class Stdout {
    static func write(bytes: Data) {
        bytes.withUnsafeBytes { (p: UnsafeRawBufferPointer) -> Void in
            _ = _write(1, p.baseAddress, p.count)
        }
    }
}
