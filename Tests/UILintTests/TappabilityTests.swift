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
    
    func testUILabelTruncationZeroFrame() {
        let origin = CGPoint(x: 100, y: 100)
        let button = UIButton(frame: CGRect(origin: origin, size: CGSize(width: 100, height: 100)))
        let over = UIView(frame: CGRect(origin: origin, size: CGSize(width: 50, height: 100)))
        let under = UIImageView(frame: CGRect(origin: origin, size: CGSize(width: 100, height: 50)))
        sut.view.addSubview(under)
        sut.view.addSubview(button)
        sut.view.addSubview(over)
        let lint = UILint(view: sut.view)
        let findings = lint!.findings
        print(findings.map { $0.debugDescription }.joined(separator: "\n"))
        let tapFindings = findings.filter { $0.message == "Tappable view UIButton is obscured by UIView" }
        XCTAssertEqual(tapFindings.count, 1)
        XCTAssertEqual(tapFindings[0].severity, .error)
    }
    
}
