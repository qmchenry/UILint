//
//  GlobalConfigTests.swift
//  
//
//  Created by Quinn McHenry on 6/9/20.
//

import XCTest
@testable import UILint

final class GlobalConfigTests: XCTestCase {

    var sut: UIViewController!

    override func setUp() {
        super.setUp()
        sut = UIViewController()
        QAConfig.shared.reset()
    }

    func testExcludedChecks() {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 157, height: 41))
        label.text = "This text is two lines\nlong for it\'s own good!"
        label.numberOfLines = 2
        sut.view.addSubview(label)
        let lint = UILint(view: sut.view)

        QAConfig.shared.excludedChecks.append(LabelTruncation.self)
        let findings = lint!.findings
        // sut without exclusions would contain 2 findings, LabelTruncation & LabelVerticalClipping
        XCTAssertEqual(findings.count, 1)
        XCTAssertFalse(findings.contains { $0.message.hasPrefix(LabelTruncation().description) })
        XCTAssertTrue(findings.contains { $0.message.hasPrefix(LabelVerticalClipping().description) })
    }

    func testExcludedFontNames() {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 157, height: 141))
        label.font = UIFont(name: "AvenirNext-HeavyItalic", size: 22)
        label.text = "This text is in AvenirNext-HeavyItalic!"
        label.numberOfLines = 0
        sut.view.addSubview(label)
        let label2 = UILabel(frame: CGRect(x: 0, y: 200, width: 157, height: 141))
        label2.font = UIFont(name: "AvenirNext-Bold", size: 22)
        label2.text = "This text is in AvenirNext-Bold!"
        label2.numberOfLines = 0
        sut.view.addSubview(label2)
        let lint = UILint(view: sut.view)

        QAConfig.shared.expectedFontNames.append("AvenirNext-HeavyItalic")
        let findings = lint!.findings
        XCTAssertEqual(findings.count, 1)
        XCTAssertTrue(findings.contains { $0.message.hasPrefix(LabelUnexpectedFont().description) })
        XCTAssertTrue(findings.contains { $0.message.contains("AvenirNext-Bold") })
    }

    func testExcludedFontNames2() {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 157, height: 141))
        label.font = UIFont(name: "AvenirNext-HeavyItalic", size: 22)
        label.text = "This text is in AvenirNext-HeavyItalic!"
        label.numberOfLines = 0
        sut.view.addSubview(label)
        let label2 = UILabel(frame: CGRect(x: 0, y: 200, width: 157, height: 141))
        label2.font = UIFont(name: "AvenirNext-Bold", size: 22)
        label2.text = "This text is in AvenirNext-Bold!"
        label2.numberOfLines = 0
        sut.view.addSubview(label2)
        let lint = UILint(view: sut.view)

        QAConfig.shared.expectedFontNames.append("AvenirNext-HeavyItalic")
        QAConfig.shared.expectedFontNames.append("AvenirNext-Bold")
        let findings = lint!.findings
        XCTAssertEqual(findings.count, 0)
    }


}
