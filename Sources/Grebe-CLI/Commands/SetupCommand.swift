//
//  SetupCommand.swift
//
//
//  Created by Tim Mewe on 25.01.20.
//

import Foundation

internal class SetupCommand: IExecutableCommand {
    // MARK: - External Dependencies
    
    private let version: String
    
    // MARK: - Lifecycle
    
    init(version: String) {
        self.version = version
    }
    
    // MARK: - ICommand
    
    func run() throws {}
    
    // MARK: - Private Functions
}
