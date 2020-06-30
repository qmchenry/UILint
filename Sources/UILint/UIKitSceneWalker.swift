//
//  UIKitSceneWalker.swift
//
//  Created by Quinn McHenry on 6/30/20.
//

import UIKit

struct UIKitSceneWalker {

    static func walk(view: UIView, context: LintingContext, currentDepth startingDepth: Int = 0) -> [Element] {
        var currentDepth = startingDepth

        func recurse(_ view: UIView, level: Int) -> [Element] {
            let viewOutput = [element(for: view, depth: currentDepth, level: level, context: context)]
                .compactMap { $0 }
            if !viewOutput.isEmpty {
                currentDepth += 1
            }
            return view.allSubviews.compactMap { recurse($0, level: level + 1) }.reduce(viewOutput, +)
        }

        return recurse(view, level: 0)
    }

    private static func element(for view: UIView, depth: Int, level: Int, context: LintingContext) -> Element? {
        guard UILintConfig.shared.ignoreUnderscoredClasses, !view.className.hasPrefix("_") else { return nil }
        if let label = view as? UILabel {
            return Label(label, depth: depth, level: level, context: context)
        }
        if let button = view as? UIButton {
            return Button(button, depth: depth, level: level, context: context)
        }
        if let image = view as? UIImageView {
            return Image(image, depth: depth, level: level, context: context)
        }
        return Element(view, depth: depth, level: level, context: context)
    }
}
