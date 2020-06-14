//
//  QAConfig.swift
//  
//
//  Created by Quinn McHenry on 6/5/20.
//

import Foundation

public struct UILintConfig {
    public static var shared = UILintConfig()

    /// If not empty, findings will be issued when fonts are discovered that are not in this list
    public var expectedFontNames = [String]()

    /// If a QACheck is included in this array, that check will be skipped when UILint is run
    public var excludedChecks = [Check.Type]()

    public func reset() {
        Self.shared.expectedFontNames = []
        Self.shared.excludedChecks = []
    }
}

public protocol UILintConfigurable {
    func shouldLint(element: Element, check: Check.Type) -> Bool
}
