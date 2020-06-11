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
        let lint = UILint(view: sut.view)
        let findings = lint!.findings
        XCTAssertEqual(findings.count, 2)
        XCTAssertTrue(findings.contains { $0.description == LabelTruncation().description })
        XCTAssertTrue(findings.contains { $0.description == LabelVerticalClipping().description })
        XCTAssertEqual(findings[0].severity, .error)
        XCTAssertEqual(findings[1].severity, .error)
    }

    func testUILabelTruncationTinyFrame() {
        let label = UILabel(frame: CGRect(origin: .zero, size: CGSize(width: 1, height: 1)))
        label.text = "Some long text here"
        sut.view.addSubview(label)
        let lint = UILint(view: sut.view)
        let findings = lint!.findings
        XCTAssertEqual(findings.count, 2)
        XCTAssertTrue(findings.contains { $0.description == LabelTruncation().description })
        XCTAssertTrue(findings.contains { $0.description == LabelVerticalClipping().description })
        XCTAssertEqual(findings[0].severity, .error)
        XCTAssertEqual(findings[1].severity, .error)
    }

    func testUILabelTruncationTinyHeight() {
        let label = UILabel(frame: CGRect(origin: .zero, size: CGSize(width: 200, height: 1)))
        label.text = "Some long text here"
        sut.view.addSubview(label)
        let lint = UILint(view: sut.view)
        XCTAssertEqual(lint?.findings.count, 1)
        XCTAssertEqual(lint?.findings.first?.severity, .error)
        XCTAssertTrue(lint!.findings.contains { $0.description == LabelVerticalClipping().description })
    }

    func testUILabelNoTruncationSingleLine() {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 180, height: 57))
        label.text = "This text is just right."
        sut.view.addSubview(label)
        let lint = UILint(view: sut.view)
        XCTAssertEqual(lint?.findings.count, 0)
    }

    func testUILabelEmptyNoTruncationSingleLine() {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 1, height: 57))
        label.text = ""
        sut.view.addSubview(label)
        let lint = UILint(view: sut.view)
        XCTAssertEqual(lint?.findings.count, 0)
    }

    func testUILabelTruncationSingleLine() {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 180, height: 57))
        label.text = "This text is too long for it\'s own good!"
        sut.view.addSubview(label)
        let lint = UILint(view: sut.view)
        XCTAssertEqual(lint?.findings.count, 1)
        XCTAssertEqual(lint?.findings.first?.severity, .error)
        XCTAssertEqual(lint!.findings[0].description, LabelTruncation().description)
    }

    func testUILabelNoTruncationMultiline() {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 357, height: 41))
        label.text = "This text is two lines\nlong for it\'s own good!"
        label.numberOfLines = 2
        sut.view.addSubview(label)
        let lint = UILint(view: sut.view)
        XCTAssertEqual(lint?.findings.count, 0)
    }

    func testUILabelTruncationMultiline() {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 157, height: 61))
        label.text = "This text is two lines\nlong for it\'s own good!"
        label.numberOfLines = 2
        sut.view.addSubview(label)
        let lint = UILint(view: sut.view)
        XCTAssertEqual(lint?.findings.count, 1)
        XCTAssertEqual(lint?.findings.first?.severity, .error)
        XCTAssertEqual(lint!.findings[0].description, LabelTruncation().description)
    }

    func testUILabelTruncationMultilineShort() {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 157, height: 41))
        label.text = "This text is two lines\nlong for it\'s own good!"
        label.numberOfLines = 2
        sut.view.addSubview(label)
        let lint = UILint(view: sut.view)
        let findings = lint!.findings
        XCTAssertEqual(findings.count, 2)
        XCTAssertTrue(findings.contains { $0.description == LabelTruncation().description })
        XCTAssertTrue(findings.contains { $0.description == LabelVerticalClipping().description })
        XCTAssertEqual(findings[0].severity, .error)
        XCTAssertEqual(findings[1].severity, .error)
    }

    func testUILabelClippedVertically() {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 157, height: 1))
        label.text = "This text is text."
        sut.view.addSubview(label)
        let lint = UILint(view: sut.view)
        XCTAssertEqual(lint?.findings.count, 1)
        XCTAssertEqual(lint?.findings.first?.severity, .error)
        XCTAssertEqual(lint!.findings[0].description, LabelVerticalClipping().description)
    }

    func testUILabelEmptyNotClippedVertically() {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 157, height: 1))
        label.text = ""
        sut.view.addSubview(label)
        let lint = UILint(view: sut.view)
        XCTAssertEqual(lint?.findings.count, 0)
    }

    func disabled_testUILabelOffscreen() {
        let size = CGSize(width: 200, height: 50)
        let windowSize = CGSize(width: 320, height: 480)
        sut.view.frame = CGRect(origin: .zero, size: windowSize)

        // need to find a way to sneak windowSize into QAElement.Base
        func isOffscreen(origin: CGPoint) -> Bool {
            let view = UILabel(frame: CGRect(origin: origin, size: size))
            let element = Element(view: view, depth: 0, level: 1)!
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
