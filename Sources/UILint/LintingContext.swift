//
//  LintingContext.swift
//
//  Created by Quinn McHenry on 6/30/20.
//

import UIKit

public struct LintingContext {
    let windowSize: CGSize
    let screenshot: UIImage?
    let safeAreaRect: CGRect
    let traitCollection: UITraitCollection
    let shouldLint: ((Element, Check.Type) -> Bool)?
}
