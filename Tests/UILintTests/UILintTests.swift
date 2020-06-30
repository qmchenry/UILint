import XCTest
@testable import UILint

final class UILintTests: XCTestCase {

    var sut: UIViewController!

    override func setUp() {
        super.setUp()
        sut = UIViewController()
        UILintConfig.shared.reset()
    }

    func testDepth() {
        let view = UIView() // 0
        view.addSubview(UISlider()) // 3
        view.addSubview(UIImageView()) // 4
        sut.view.addSubview(UIImageView()) // 1
        sut.view.addSubview(view) // 2
        sut.view.addSubview(UILabel()) // 5

        let lint = UILintSession(view: sut.view)
        XCTAssertEqual(lint?.elements.count, 6)
        XCTAssertEqual(lint?.elements[0].depth, 0)
        XCTAssertEqual(lint?.elements[1].depth, 1)
        XCTAssertEqual(lint?.elements[2].depth, 2)
        XCTAssertEqual(lint?.elements[3].depth, 3)
        XCTAssertEqual(lint?.elements[4].depth, 4)
        XCTAssertEqual(lint?.elements[5].depth, 5)

        XCTAssertEqual(lint?.elements[0].className, "UIView")
        XCTAssertEqual(lint?.elements[1].className, "UIImageView")
        XCTAssertEqual(lint?.elements[2].className, "UIView")
        XCTAssertEqual(lint?.elements[3].className, "UISlider")
        XCTAssertEqual(lint?.elements[4].className, "UIImageView")
        XCTAssertEqual(lint?.elements[5].className, "UILabel")

    }

}
