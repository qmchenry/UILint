//
//  QAConfig.swift
//  
//
//  Created by Quinn McHenry on 6/5/20.
//

import Foundation

public struct QAConfig {
    // If not empty, findings will be issued when fonts are discovered that are not in this list
    public static var expectedFontNames = [String]()
    public static var excludedChecks = [QACheck.Type]()
}
