//
//  UILint.swift
//  UILint
//
//  Created by Quinn McHenry on 5/18/20.
//  Copyright © 2020 Quinn McHenry. All rights reserved.
//

import UIKit

public struct UILint {

    static var sessions = [UILintSession]()
    public static let singleReportURL = URL(fileURLWithPath: "/tmp/uilint-report.pdf")

    public static func clearSessions() {
        sessions.removeAll()
    }

    static weak var window: UIWindow?
    public static func register(window: UIWindow?) {
        guard let window = window else { return }
        deregister()
        Self.window = window
        let recognizer = UILintGestureRecognizer {
            guard let window = Self.window,
                let rootVC = window.rootViewController,
                let session = UILintSession(view: rootVC.view)
            else { return }
            sessions.append(session)
            let pdfData = session.makePDF()
            try? pdfData.write(to: singleReportURL)
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
