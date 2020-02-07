//
//  Gitignore.swift
//
//
//  Created by Tim Mewe on 07.02.20.
//

import Foundation

internal struct Gitignore: IWritableFile {
    var name: String = "/.gitignore"

    var content: String { """
        .build
        DerivedData
        /.previous-build
        xcuserdata
        .DS_Store
        *~
        \\#*
        .\\#*
        .*.sw[nop]
        *.xcscmblueprint
        /default.profraw
        *.xcodeproj
        Utilities/Docker/*.tar.gz
        .swiftpm
        Package.resolved
        /build
        *.pyc
    """
    }
}
