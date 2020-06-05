//
//  TappabilityTests.swift
//  UILintTests
//
//  Created by Quinn McHenry on 5/26/20.
//

import XCTest
@testable import UILint

class TappabilityTests: XCTestCase {

    var sut: UIViewController!

    override func setUp() {
        super.setUp()
        sut = UIViewController()
    }

    func testUIButtonPartiallyCovered() {
        let origin = CGPoint(x: 100, y: 100)
        let button = UIButton(frame: CGRect(origin: origin, size: CGSize(width: 100, height: 100)))
        let over = UIView(frame: CGRect(origin: origin, size: CGSize(width: 50, height: 100)))
        let under = UIImageView(frame: CGRect(origin: origin, size: CGSize(width: 100, height: 50)))
        sut.view.addSubview(under)
        sut.view.addSubview(button)
        sut.view.addSubview(over)
        let lint = UILint(view: sut.view)
        let findings = lint!.findings
        let tapFindings = findings.filter { $0.message == "Tappable view UIButton is obscured by UIView" }
        XCTAssertEqual(tapFindings.count, 1)
        XCTAssertEqual(tapFindings[0].severity, .error)
    }

    func testUIButtonPartiallyCovered1x1pt() {
        let origin = CGPoint(x: 100, y: 100)
        let button = UIButton(frame: CGRect(origin: origin, size: CGSize(width: 100, height: 100)))
        let over = UIView(frame: CGRect(origin: origin, size: CGSize(width: 1, height: 1)))
        let under = UIImageView(frame: CGRect(origin: origin, size: CGSize(width: 100, height: 50)))
        sut.view.addSubview(under)
        sut.view.addSubview(button)
        sut.view.addSubview(over)
        let lint = UILint(view: sut.view)
        let findings = lint!.findings
        let tapFindings = findings.filter { $0.message == "Tappable view UIButton is obscured by UIView" }
        XCTAssertEqual(tapFindings.count, 1)
        XCTAssertEqual(tapFindings[0].severity, .error)
    }

    func testUIButtonPartiallyCovered0x0pt() {
        let origin = CGPoint(x: 100, y: 100)
        let button = UIButton(frame: CGRect(origin: origin, size: CGSize(width: 100, height: 100)))
        let over = UIView(frame: CGRect(origin: origin, size: CGSize(width: 0, height: 0)))
        let under = UIImageView(frame: CGRect(origin: origin, size: CGSize(width: 100, height: 50)))
        sut.view.addSubview(under)
        sut.view.addSubview(button)
        sut.view.addSubview(over)
        let lint = UILint(view: sut.view)
        let findings = lint!.findings
        XCTAssertEqual(findings.count, 0)
    }

    func testUIButtonNotCovered() {
        let origin = CGPoint(x: 100, y: 100)
        let button = UIButton(frame: CGRect(origin: origin, size: CGSize(width: 100, height: 100)))
        let over = UIView(frame: CGRect(origin: CGPoint(x: 200, y: 200), size: CGSize(width: 50, height: 100)))
        let under = UIImageView(frame: CGRect(origin: origin, size: CGSize(width: 100, height: 50)))
        sut.view.addSubview(under)
        sut.view.addSubview(button)
        sut.view.addSubview(over)
        let lint = UILint(view: sut.view)
        let findings = lint!.findings
        XCTAssertEqual(findings.count, 0)
    }

    func testUIButtonCoveredUIEDisabled() {
        let origin = CGPoint(x: 100, y: 100)
        let button = UIButton(frame: CGRect(origin: origin, size: CGSize(width: 100, height: 100)))
        let over = UIView(frame: CGRect(origin: origin, size: CGSize(width: 50, height: 100)))
        over.isUserInteractionEnabled = false
        let under = UIImageView(frame: CGRect(origin: origin, size: CGSize(width: 100, height: 50)))
        sut.view.addSubview(under)
        sut.view.addSubview(button)
        sut.view.addSubview(over)
        let lint = UILint(view: sut.view)
        let findings = lint!.findings
        XCTAssertEqual(findings.count, 0)
    }

    func testUIButtonCoveredByHiddenView() {
        let origin = CGPoint(x: 100, y: 100)
        let button = UIButton(frame: CGRect(origin: origin, size: CGSize(width: 100, height: 100)))
        let over = UIView(frame: CGRect(origin: origin, size: CGSize(width: 50, height: 100)))
        over.isHidden = true
        let under = UIImageView(frame: CGRect(origin: origin, size: CGSize(width: 100, height: 50)))
        sut.view.addSubview(under)
        sut.view.addSubview(button)
        sut.view.addSubview(over)
        let lint = UILint(view: sut.view)
        let findings = lint!.findings
        XCTAssertEqual(findings.count, 0)
    }

    func testUIViewWithGestureRecognizerPartiallyCovered() {
        let origin = CGPoint(x: 100, y: 100)
        let tappable = UIView(frame: CGRect(origin: origin, size: CGSize(width: 100, height: 100)))
        let gestureRecognizer = UITapGestureRecognizer()
        tappable.addGestureRecognizer(gestureRecognizer)
        let over = UIView(frame: CGRect(origin: origin, size: CGSize(width: 50, height: 100)))
        let under = UIImageView(frame: CGRect(origin: origin, size: CGSize(width: 100, height: 50)))
        sut.view.addSubview(under)
        sut.view.addSubview(tappable)
        sut.view.addSubview(over)
        let lint = UILint(view: sut.view)
        let findings = lint!.findings
        let tapFindings = findings.filter { $0.message == "Tappable view UIView is obscured by UIView" }
        XCTAssertEqual(tapFindings.count, 1)
        XCTAssertEqual(tapFindings[0].severity, .error)
    }

    func testUIViewWithDisabledGestureRecognizerPartiallyCovered() {
        let origin = CGPoint(x: 100, y: 100)
        let tappable = UIView(frame: CGRect(origin: origin, size: CGSize(width: 100, height: 100)))
        let gestureRecognizer = UITapGestureRecognizer()
        gestureRecognizer.isEnabled = false
        tappable.addGestureRecognizer(gestureRecognizer)
        let over = UIView(frame: CGRect(origin: origin, size: CGSize(width: 50, height: 100)))
        let under = UIImageView(frame: CGRect(origin: origin, size: CGSize(width: 100, height: 50)))
        sut.view.addSubview(under)
        sut.view.addSubview(tappable)
        sut.view.addSubview(over)
        let lint = UILint(view: sut.view)
        let findings = lint!.findings
        let tapFindings = findings.filter { $0.message == "Tappable view UIView is obscured by UIView" }
        XCTAssertEqual(tapFindings.count, 0)
    }

}
