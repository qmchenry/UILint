//
//  UILabelTests.swift
//  UILintTests
//
//  Created by Quinn McHenry on 5/26/20.
//

import XCTest
@testable import UILint

class UILabelTests: XCTestCase {

    var sut: UIViewController!

    override func setUp() {
        super.setUp()
        sut = UIViewController()
        UILintConfig.shared.reset()
    }

    func testUILabelTruncationZeroFrame() {
        let label = UILabel(frame: CGRect(origin: .zero, size: .zero))
        label.text = "Some long text here"
        sut.view.addSubview(label)
        let lint = UILintSession(view: sut.view)
        let findings = lint!.findings
        XCTAssertTrue(findings.contains { $0.description == LabelTruncation().description })
        XCTAssertTrue(findings.contains { $0.description == LabelVerticalClipping().description })
    }

    func testUILabelTruncationTinyFrame() {
        let label = UILabel(frame: CGRect(origin: .zero, size: CGSize(width: 1, height: 1)))
        label.text = "Some long text here"
        sut.view.addSubview(label)
        let lint = UILintSession(view: sut.view)!
        let findings = lint.findings
        XCTAssertTrue(findings.contains { $0.description == LabelTruncation().description })
        XCTAssertTrue(findings.contains { $0.description == LabelVerticalClipping().description })
    }

    func testUILabelTruncationTinyHeight() {
        let label = UILabel(frame: CGRect(origin: .zero, size: CGSize(width: 200, height: 1)))
        label.text = "Some long text here"
        sut.view.addSubview(label)
        let lint = UILintSession(view: sut.view)!
        XCTAssertEqual(lint.findings.first?.severity, .error)
        XCTAssertTrue(lint.findings.contains { $0.description == LabelVerticalClipping().description })
    }

    func testUILabelNoTruncationSingleLine() {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 180, height: 57))
        label.text = "This text is just right."
        sut.view.addSubview(label)
        let lint = UILintSession(view: sut.view)!
        XCTAssertFalse(lint.findings.contains { $0.description == LabelTruncation().description })
        XCTAssertFalse(lint.findings.contains { $0.description == LabelVerticalClipping().description })
    }

    func testUILabelEmptyNoTruncationSingleLine() {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 1, height: 57))
        label.text = ""
        sut.view.addSubview(label)
        let lint = UILintSession(view: sut.view)!
        XCTAssertFalse(lint.findings.contains { $0.description == LabelTruncation().description })
        XCTAssertFalse(lint.findings.contains { $0.description == LabelVerticalClipping().description })
    }

    func testUILabelTruncationSingleLine() {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 180, height: 57))
        label.text = "This text is too long for it\'s own good!"
        sut.view.addSubview(label)
        let lint = UILintSession(view: sut.view)!
        XCTAssertEqual(lint.findings.first?.severity, .error)
        XCTAssertTrue(lint.findings.contains { $0.description == LabelTruncation().description })
    }

    func testUILabelNoTruncationMultiline() {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 357, height: 41))
        label.text = "This text is two lines\nlong for it\'s own good!"
        label.numberOfLines = 2
        sut.view.addSubview(label)
        let lint = UILintSession(view: sut.view)!
        XCTAssertFalse(lint.findings.contains { $0.description == LabelTruncation().description })
        XCTAssertFalse(lint.findings.contains { $0.description == LabelVerticalClipping().description })
    }

    func testUILabelTruncationMultiline() {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 157, height: 61))
        label.text = "This text is two lines\nlong for it\'s own good!"
        label.numberOfLines = 2
        sut.view.addSubview(label)
        let lint = UILintSession(view: sut.view)!
        XCTAssertEqual(lint.findings.first?.severity, .error)
        XCTAssertTrue(lint.findings.contains { $0.description == LabelTruncation().description })
    }

    func testUILabelTruncationMultilineShort() {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 157, height: 41))
        label.text = "This text is two lines\nlong for it\'s own good!"
        label.numberOfLines = 2
        sut.view.addSubview(label)
        let lint = UILintSession(view: sut.view)!
        let findings = lint .findings
        XCTAssertEqual(findings.filter { $0.description == LabelTruncation().description }.count, 1)
        XCTAssertEqual(findings.filter { $0.description == LabelVerticalClipping().description }.count, 1)
    }

    func testUILabelClippedVertically() {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 157, height: 1))
        label.text = "This text is text."
        sut.view.addSubview(label)
        let lint = UILintSession(view: sut.view)!
        XCTAssertEqual(lint.findings.first?.severity, .error)
        XCTAssertTrue(lint.findings.contains { $0.description == LabelVerticalClipping().description })
    }

    func testUILabelEmptyNotClippedVertically() {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 157, height: 1))
        label.text = ""
        sut.view.addSubview(label)
        let lint = UILintSession(view: sut.view)!
        XCTAssertFalse(lint.findings.contains { $0.description == LabelTruncation().description })
        XCTAssertFalse(lint.findings.contains { $0.description == LabelVerticalClipping().description })
    }

    func disabled_testUILabelOffscreen() {
        let size = CGSize(width: 200, height: 50)
        let windowSize = CGSize(width: 320, height: 480)
        sut.view.frame = CGRect(origin: .zero, size: windowSize)

        let context = LintingContext(windowSize: windowSize,
                                     screenshot: nil,
                                     safeAreaRect: CGRect(origin: .zero, size: windowSize),
                                     traitCollection: UITraitCollection(),
                                     shouldLint: nil)
        // need to find a way to sneak windowSize into QAElement.Base
        func isOffscreen(origin: CGPoint) -> Bool {
            let view = UILabel(frame: CGRect(origin: origin, size: size))
            let element = Label(view, depth: 0, level: 1, context: context)
            return element.isLabelOffscreen(windowSize: windowSize)
        }
        XCTAssertFalse(isOffscreen(origin: .zero))
        XCTAssertTrue(isOffscreen(origin: CGPoint(x: 121, y: 0)))
        XCTAssertTrue(isOffscreen(origin: CGPoint(x: -1, y: 0)))
        XCTAssertTrue(isOffscreen(origin: CGPoint(x: 0, y: -1)))
        XCTAssertFalse(isOffscreen(origin: CGPoint(x: 120, y: 430)))
        XCTAssertTrue(isOffscreen(origin: CGPoint(x: 120, y: 431)))
        XCTAssertTrue(isOffscreen(origin: CGPoint(x: 121, y: 430)))
        XCTAssertTrue(isOffscreen(origin: CGPoint(x: 121, y: 431)))
    }

}
