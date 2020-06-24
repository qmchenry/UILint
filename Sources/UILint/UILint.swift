//
//  UILint.swift
//  UILint
//
//  Created by Quinn McHenry on 5/18/20.
//  Copyright © 2020 Quinn McHenry. All rights reserved.
//

import UIKit

public struct UILint {

    let elements: [Element]
    let context: LintingContext

    public init?(view: UIView) {
        guard let grandparentVC = view.parentViewController(), let grandparent = grandparentVC.view else {
            print("Unable to find parent view controller from view")
            return nil
        }

        let screenshot = grandparent.takeScreenshot()
        let context = LintingContext(windowSize: screenshot.size,
                                     screenshot: screenshot,
                                     safeAreaRect: grandparent.frame.inset(by: grandparent.safeAreaInsets),
                                     traitCollection: grandparentVC.traitCollection,
                                     shouldLint: (grandparentVC as? UILintConfigurable)?.shouldLint(element:check:))

        var currentDepth = 0

        func recurse(_ view: UIView, level: Int) -> [Element] {
            let viewOutput = [Element(view: view, depth: currentDepth, level: level, context: context)]
                .compactMap { $0 }
            currentDepth += 1
            return view.allSubviews.compactMap { recurse($0, level: level + 1) }.reduce(viewOutput, +)
        }

        self.context = context
        elements = recurse(grandparent, level: 0)
    }

    var findings: [Finding] {
        elements.flatMap {
            $0.findings(elements: elements, context: context)
        }
    }

    public func makePDF() -> Data {
        Report(elements: elements, findings: findings, details: context).makePDF()
    }

    static weak var window: UIWindow?
    public static func register(window: UIWindow?) {
        guard let window = window else { return }
        deregister()
        Self.window = window
        let recognizer = UILintGestureRecognizer {
            guard let window = Self.window,
                let rootVC = window.rootViewController,
                let lint = UILint(view: rootVC.view)
            else { return }
            let pdfData = lint.makePDF()
            let activityVC = UIActivityViewController(activityItems: [pdfData], applicationActivities: nil)
            activityVC.modalPresentationStyle = .overFullScreen
            rootVC.topmostViewController().present(activityVC, animated: true)
            if let popOver = activityVC.popoverPresentationController {
                popOver.sourceView = rootVC.topmostViewController().view
                popOver.sourceRect = .zero
            }
        }
        window.addGestureRecognizer(recognizer)
    }

    public static func deregister() {
        guard let window = Self.window, let recognizers = window.gestureRecognizers
            else { return }
        recognizers.filter { $0 is UILintGestureRecognizer }
            .forEach { window.removeGestureRecognizer($0) }
        Self.window = nil
    }
}

final class UILintGestureRecognizer: UITapGestureRecognizer {
    private var action: () -> Void

    init(action: @escaping () -> Void) {
        self.action = action
        super.init(target: nil, action: nil)
        numberOfTapsRequired = 2
        numberOfTouchesRequired = 2
        addTarget(self, action: #selector(callback))
    }

    @objc private func callback() {
        action()
    }
}

public struct LintingContext {
    let windowSize: CGSize
    let screenshot: UIImage?
    let safeAreaRect: CGRect
    let traitCollection: UITraitCollection
    // if there's a generic way to use Element instead of using it's base.accessibilityIdentifier and tag...
    let shouldLint: ((String?, Int?, Check.Type) -> Bool)?
}
