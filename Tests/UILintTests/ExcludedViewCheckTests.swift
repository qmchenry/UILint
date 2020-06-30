//
//  ExcludedViewCheckTests.swift
//  
//
//  Created by Quinn McHenry on 6/13/20.
//

import XCTest
@testable import UILint

private class ViewController: UIViewController, UILintConfigurable {
    func shouldLint(element: Element, check: Check.Type) -> Bool {
        switch (element.tag, element.accessibilityIdentifier, check) {
        case (10, _, _): return false
        case (20, _, is LabelVerticalClipping.Type): return false
        case (_, "Don't check this", _): return false
        case (_, "Don't check this for vertical clipping", is LabelVerticalClipping.Type): return false
        default: return true
        }
    }
}

final class ExcludedViewCheckTests: XCTestCase {

    private var sut: ViewController!

    override func setUp() {
        super.setUp()
        sut = ViewController()
        UILintConfig.shared.reset()
    }

    func testExcludeSingleViewByTag() {
        let label = UILabel(frame: CGRect(origin: .zero, size: .zero))
        label.text = "Some long text here"
        label.tag = 10
        sut.view.addSubview(label)
        let lint = UILintSession(view: sut.view)
        let findings = lint!.findings
        XCTAssertEqual(findings.count, 0)
        // in testUILabelTruncationZeroFrame() has two Findings
    }

    func testExcludeSingleCheckSingleViewByTag() {
        let label = UILabel(frame: CGRect(origin: .zero, size: .zero))
        label.text = "Some long text here"
        label.tag = 20
        sut.view.addSubview(label)
        let lint = UILintSession(view: sut.view)
        let findings = lint!.findings
        XCTAssertTrue(findings.contains { $0.description == LabelTruncation().description })
        XCTAssertFalse(findings.contains { $0.description == LabelVerticalClipping().description })
    }

    func testExcludeSingleViewByAccessibilityID() {
        let label = UILabel(frame: CGRect(origin: .zero, size: .zero))
        label.text = "Some long text here"
        label.accessibilityIdentifier = "Don't check this"
        sut.view.addSubview(label)
        let lint = UILintSession(view: sut.view)
        let findings = lint!.findings
        XCTAssertEqual(findings.count, 0)
        // in testUILabelTruncationZeroFrame() has two Findings
    }

    func testExcludeSingleCheckSingleViewByAccessibilityID() {
        let label = UILabel(frame: CGRect(origin: .zero, size: .zero))
        label.text = "Some long text here"
        label.accessibilityIdentifier = "Don't check this for vertical clipping"
        sut.view.addSubview(label)
        let lint = UILintSession(view: sut.view)
        let findings = lint!.findings
        XCTAssertTrue(findings.contains { $0.description == LabelTruncation().description })
        XCTAssertFalse(findings.contains { $0.description == LabelVerticalClipping().description })
    }
}
