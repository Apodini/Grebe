//
//  ReadmeConent.wift
//
//
//  Created by Tim Mewe on 24.01.20.
//

import Foundation

internal struct Readme: IWritableFile {
    let name: String = "/README.md"

    let content: String = """
    # Grebe Package

    A description of this package.
    """
}
