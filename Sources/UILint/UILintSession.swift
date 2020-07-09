//
//  UILintSession.swift
//  
//
//  Created by Quinn McHenry on 6/30/20.
//

import UIKit

public struct UILintSession {
    let elements: [Element]
    let context: LintingContext

    var findings: [Finding] {
        elements.flatMap {
            $0.findings(elements: elements, context: context)
        }
    }

    public func makePDF() -> Data {
        let allFindings = findings
        let report = Report(elements: elements, findings: allFindings, details: context).makePDF()
        #if targetEnvironment(simulator)
        try? report.write(to: UILint.singleReportURL)
        try? Data(summary(findings: allFindings).utf8).write(to: UILint.singleResultsURL)
        #endif
        return report
    }

    public func summary(findings: [Finding]) -> String {
        let errors = findings.filter { $0.severity == .error }.count
        let warnings = findings.filter { $0.severity == .warning }.count
        if errors + warnings == 0 {
            return "No findings"
        }
        return "\(errors) error\(errors == 1 ? "" : "s"), \(warnings) warning\(warnings == 1 ? "" : "s")"
    }

    public func summary() -> String {
        summary(findings: findings)
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

        elements = UIKitSceneWalker.walk(view: grandparent, context: context)
    }
}
