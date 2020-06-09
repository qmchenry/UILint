//
//  TouchSizeTests.swift
//  UILintTests
//
//  Created by Quinn McHenry on 5/26/20.
//

import XCTest
@testable import UILint

class TouchSizeTests: XCTestCase {

    var sut: UIViewController!

    override func setUp() {
        super.setUp()
        sut = UIViewController()
        UILintConfig.shared.reset()
    }

    func testUIButtonMinimumHeight() {
        let button = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 44, height: 43)))
        sut.view.addSubview(button)
        let lint = UILint(view: sut.view)
        let findings = lint!.findings
        XCTAssertEqual(findings.count, 1)
        XCTAssert(findings[0].message.hasPrefix(MinimumTapSize().description))
        XCTAssertEqual(findings[0].severity, .error)
    }

    func testUIButtonMinimumWidth() {
        let button = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 43, height: 44)))
        sut.view.addSubview(button)
        let lint = UILint(view: sut.view)
        let findings = lint!.findings
        XCTAssertEqual(findings.count, 1)
        XCTAssert(findings[0].message.hasPrefix(MinimumTapSize().description))
        XCTAssertEqual(findings[0].severity, .error)
    }

    func testUIButtonMinimumWidthAndHeight() {
        let button = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 1, height: 1)))
        sut.view.addSubview(button)
        let lint = UILint(view: sut.view)
        let findings = lint!.findings
        XCTAssertEqual(findings.count, 1)
        XCTAssert(findings[0].message.hasPrefix(MinimumTapSize().description))
        XCTAssertEqual(findings[0].severity, .error)
    }

    func testUIButtonZeroSize() {
        let button = UIButton(frame: CGRect(origin: .zero, size: .zero))
        sut.view.addSubview(button)
        let lint = UILint(view: sut.view)
        let findings = lint!.findings
        XCTAssertEqual(findings.count, 1)
        XCTAssert(findings[0].message.hasPrefix(MinimumTapSize().description))
        XCTAssertEqual(findings[0].severity, .error)
    }

    func testUIButtonMinimumGoodSize() {
        let button = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 44, height: 44)))
        sut.view.addSubview(button)
        let lint = UILint(view: sut.view)
        let findings = lint!.findings
        XCTAssertEqual(findings.count, 0)
    }

    // UIView + Gesture recognizer

    func testUIViewGRMinimumHeight() {
        let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 44, height: 43)))
        view.addGestureRecognizer(UITapGestureRecognizer())
        sut.view.addSubview(view)
        let lint = UILint(view: sut.view)
        let findings = lint!.findings
        XCTAssertEqual(findings.count, 1)
        XCTAssert(findings[0].message.hasPrefix(MinimumTapSize().description))
        XCTAssertEqual(findings[0].severity, .error)
    }

    func testUIViewGRMinimumWidth() {
        let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 43, height: 44)))
        view.addGestureRecognizer(UITapGestureRecognizer())
        sut.view.addSubview(view)
        let lint = UILint(view: sut.view)
        let findings = lint!.findings
        XCTAssertEqual(findings.count, 1)
        XCTAssert(findings[0].message.hasPrefix(MinimumTapSize().description))
        XCTAssertEqual(findings[0].severity, .error)
    }

    func testUIViewGRMinimumGoodSize() {
        let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 44, height: 44)))
        view.addGestureRecognizer(UITapGestureRecognizer())
        sut.view.addSubview(view)
        let lint = UILint(view: sut.view)
        let findings = lint!.findings
        XCTAssertEqual(findings.count, 0)
    }

}
