//
//  UILabelIntrinsicSizeTests.swift
//  
//
//  Created by Quinn McHenry on 7/15/20.
//

import XCTest
@testable import UILint

class UILabelIntrinsicSizeTests: XCTestCase {

    var sut: UIViewController!

    override func setUp() {
        super.setUp()
        sut = UIViewController()
        UILintConfig.shared.reset()
    }


    func testLabelIntrinsicSizeClipping() {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.text = "Hello enormous world"
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 1

        let font = label.font!

        let options: [NSStringDrawingOptions] = [
            [.usesFontLeading],
            [.usesLineFragmentOrigin],
            [.truncatesLastVisibleLine],
            [.usesDeviceMetrics],
            [.usesLineFragmentOrigin, .usesFontLeading, .usesDeviceMetrics],
        ]

        func labelSizes(text: String) {
            label.text = text
            sut.view.layoutSubviews()
            let intrinsicSize = label.bounds.size
            let limitSize =  CGSize(width: intrinsicSize.width, height: .greatestFiniteMagnitude)
            let nsText = text as NSString

            let sizes = options.map {
                nsText.boundingRect(with: limitSize, options: $0, attributes: [.font: font], context: nil).size
            }
            let stringSizes = sizes.map{$0.string(precision: 3)}.joined(separator: "\n")
            print("text: \(text)\nintrinsicSize:\n\(intrinsicSize.string(precision: 3))\nsizes:\n\(stringSizes)")
        }

        label.translatesAutoresizingMaskIntoConstraints = false
        sut.view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: sut.view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: sut.view.centerYAnchor),
        ])

        labelSizes(text: "Hello enormous world")
        labelSizes(text: "Hello world!")
        labelSizes(text: "hi world!")
        labelSizes(text: "happy birthday")
        labelSizes(text: "get off my lawn!!")
        labelSizes(text: "x")
        labelSizes(text: "iiiiiiiiiiiiii\niiiiiiiiii")
        label.numberOfLines = 2
        labelSizes(text: "iiiiiiiiiiiiii\niiiiiiiiii")
        label.numberOfLines = 1
        labelSizes(text: "Hello enormous world")
//        sut.view.layoutSubviews()
//        let lint = UILintSession(view: sut.view)!
//        print(lint.findings)
//        XCTAssertFalse(lint.findings.contains { $0.description == LabelTruncation().description })
//        XCTAssertFalse(lint.findings.contains { $0.description == LabelVerticalClipping().description })
    }


}
