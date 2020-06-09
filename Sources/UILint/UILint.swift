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
    let windowSize: CGSize
    let screenshot: UIImage?

    public init?(view: UIView) {
        guard let grandparent = view.parentViewController()?.view else {
            print("Unable to find parent view controller from view")
            return nil
        }

        var currentDepth = 0

        screenshot = grandparent.makeSnapshot()
        windowSize = screenshot?.size ?? .zero

        func recurse(_ view: UIView) -> [Element] {
            let viewOutput = [Element(view: view, depth: currentDepth)].compactMap { $0 }
            currentDepth += 1
            return view.allSubviews.compactMap { recurse($0) }.reduce(viewOutput, +)
        }

        elements = recurse(grandparent)
    }

    var findings: [Finding] {
        elements.flatMap { $0.findings(elements: elements, windowSize: windowSize, screenshot: screenshot) }
    }

    public func makePDF() -> Data {
        Report(elements: elements, findings: findings, screenshot: screenshot).makePDF()
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
            rootVC.topmostViewController().present(activityVC, animated: true)
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
