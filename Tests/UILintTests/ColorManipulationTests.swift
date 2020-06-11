//
//  ColorManipulationTests.swift
//  
//
//  Created by Quinn McHenry on 6/10/20.
//

import XCTest
@testable import UILint

final class ColorManipulationTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    func testContrastRatio() {
        // Based on values from https://contrast-ratio.com/#white-on-blue
        XCTAssertEqual(UIColor.white.contrastRatio(with: .black), 21)
        XCTAssertEqual(UIColor.black.contrastRatio(with: .black), 1)
        XCTAssertEqual(UIColor.white.contrastRatio(with: .blue), 8.59, accuracy: 0.01)
    }

    func testAverageColorSame() {
        let allBlue = [UIColor.blue, UIColor.blue, UIColor.blue, UIColor.blue]
        let averageBlue = UIColor(colors: allBlue)!
        XCTAssertEqual(averageBlue.hex, UIColor.blue.hex)
    }

    func testAverageColorWhite() {
        let colors = [UIColor.white, UIColor.white, UIColor.white, UIColor.white]
        let average = UIColor(colors: colors)!
        XCTAssertEqual(average.hex, UIColor.white.hex)
    }

    func testAverageColor() {
        let colors = [UIColor.blue, UIColor.red]
        let average = UIColor(colors: colors)!
        XCTAssertEqual(average.hex, "#800080FF")
    }

    func testUIFontIsBold() {
        XCTAssertTrue(UIFont.systemFont(ofSize: 15, weight: .bold).isBold)
        XCTAssertTrue(UIFont.systemFont(ofSize: 15, weight: .heavy).isBold)
        XCTAssertTrue(UIFont.systemFont(ofSize: 15, weight: .black).isBold)
        XCTAssertTrue(UIFont.systemFont(ofSize: 15, weight: .semibold).isBold)

        XCTAssertFalse(UIFont.systemFont(ofSize: 15, weight: .light).isBold)
        XCTAssertFalse(UIFont.systemFont(ofSize: 15, weight: .medium).isBold)
        XCTAssertFalse(UIFont.systemFont(ofSize: 15, weight: .regular).isBold)
        XCTAssertFalse(UIFont.systemFont(ofSize: 15, weight: .thin).isBold)
    }

    // https://developer.apple.com/design/human-interface-guidelines/accessibility/overview/color-and-contrast/
    //
    // Text size            Text weight         Minimum contrast ratio
    // Up to 17 pt          Any                 4.5:1
    // 18 pt and larger     Any                 3:1
    // Any                  Bold                3:1

    func testFontWeightContrastRatio() {
        let sut = LabelContrastRatio()
        let smallBold = UIFont.systemFont(ofSize: 17, weight: .bold)
        let smallRegular = UIFont.systemFont(ofSize: 17, weight: .regular)
        let bigBold = UIFont.systemFont(ofSize: 18, weight: .bold)
        let bigRegular = UIFont.systemFont(ofSize: 18, weight: .regular)
        XCTAssertTrue(sut.isValid(contrastRatio: 4.6, font: smallBold))
        XCTAssertTrue(sut.isValid(contrastRatio: 4.6, font: smallRegular))
        XCTAssertTrue(sut.isValid(contrastRatio: 4.6, font: bigBold))
        XCTAssertTrue(sut.isValid(contrastRatio: 4.6, font: bigRegular))
        XCTAssertTrue(sut.isValid(contrastRatio: 4.4, font: smallBold))
        XCTAssertFalse(sut.isValid(contrastRatio: 4.4, font: smallRegular))
        XCTAssertTrue(sut.isValid(contrastRatio: 4.4, font: bigBold))
        XCTAssertTrue(sut.isValid(contrastRatio: 4.4, font: bigRegular))
        XCTAssertTrue(sut.isValid(contrastRatio: 3, font: smallBold))
        XCTAssertFalse(sut.isValid(contrastRatio: 3, font: smallRegular))
        XCTAssertTrue(sut.isValid(contrastRatio: 3, font: bigBold))
        XCTAssertTrue(sut.isValid(contrastRatio: 3, font: bigRegular))
        XCTAssertFalse(sut.isValid(contrastRatio: 2.99, font: smallBold))
        XCTAssertFalse(sut.isValid(contrastRatio: 2.99, font: smallRegular))
        XCTAssertFalse(sut.isValid(contrastRatio: 2.99, font: bigBold))
        XCTAssertFalse(sut.isValid(contrastRatio: 2.99, font: bigRegular))
    }

}
