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
    }
    
    func testUILabelTruncationZeroFrame() {
        let label = UILabel(frame: CGRect(origin: .zero, size: .zero))
        label.text = "Some long text here"
        sut.view.addSubview(label)
        let lint = UILint(view: sut.view)
        let findings = lint!.findings
        XCTAssertEqual(findings.count, 2)
        XCTAssertTrue(findings.contains { $0.message == "Label is truncated" })
        XCTAssertTrue(findings.contains { $0.message == "Label is clipped vertically" })
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
        XCTAssertTrue(findings.contains { $0.message == "Label is truncated" })
        XCTAssertTrue(findings.contains { $0.message == "Label is clipped vertically" })
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
        XCTAssertEqual(lint?.findings.first?.message, "Label is clipped vertically")
    }
    
    func testUILabelNoTruncationSingleLine() {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 180, height: 57))
        label.text = "This text is just right."
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
        XCTAssertEqual(lint?.findings.first?.message, "Label is truncated")
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
        XCTAssertEqual(lint?.findings.first?.message, "Label is truncated")
    }
    
    func testUILabelTruncationMultilineShort() {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 157, height: 41))
        label.text = "This text is two lines\nlong for it\'s own good!"
        label.numberOfLines = 2
        sut.view.addSubview(label)
        let lint = UILint(view: sut.view)
        let findings = lint!.findings
        XCTAssertEqual(findings.count, 2)
        XCTAssertTrue(findings.contains { $0.message == "Label is truncated" })
        XCTAssertTrue(findings.contains { $0.message == "Label is clipped vertically" })
        XCTAssertEqual(findings[0].severity, .error)
        XCTAssertEqual(findings[1].severity, .error)
    }
    
    func testUILabelClippedVertically() {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 157, height: 10))
        label.text = "This text is text."
        sut.view.addSubview(label)
        let lint = UILint(view: sut.view)
        XCTAssertEqual(lint?.findings.count, 1)
        XCTAssertEqual(lint?.findings.first?.severity, .error)
        XCTAssertEqual(lint?.findings.first?.message, "Label is clipped vertically")
    }

}
