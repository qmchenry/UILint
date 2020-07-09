//
//  UILintSessionSummaryTests.swift
//  
//  Created by Quinn McHenry on 7/9/20.
//

import XCTest
@testable import UILint

class UILintSessionSummaryTests: XCTestCase {

    private var sut: UIViewController!

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
        let summary = lint!.summary()
        XCTAssertEqual(summary, "2 errors, 0 warnings")
    }

}
