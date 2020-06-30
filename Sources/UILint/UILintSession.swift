//
//  UILintSession.swift
//  
//
//  Created by Quinn McHenry on 6/30/20.
//

import UIKit

public struct UILintSession {
    var elements = [Element]()
    let context: LintingContext

    var findings: [Finding] {
        elements.flatMap {
            $0.findings(elements: elements, context: context)
        }
    }

    public func makePDF() -> Data {
        Report(elements: elements, findings: findings, details: context).makePDF()
    }

    public init?(view: UIView) {
        guard let grandparentVC = view.parentViewController(), let grandparent = grandparentVC.view else {
            print("Unable to find parent view controller from view")
            return nil
        }

        let screenshot = grandparent.takeScreenshot()
        context = LintingContext(windowSize: screenshot.size,
                                 screenshot: screenshot,
                                 safeAreaRect: grandparent.frame.inset(by: grandparent.safeAreaInsets),
                                 traitCollection: grandparentVC.traitCollection,
                                 shouldLint: (grandparentVC as? UILintConfigurable)?.shouldLint(element:check:))

        elements += UIKitSceneWalker.walk(view: grandparent, context: context)
    }
}
