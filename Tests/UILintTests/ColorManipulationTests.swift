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

}
