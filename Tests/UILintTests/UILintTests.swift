import XCTest
@testable import UILint

final class UILintTests: XCTestCase {
    
    var sut: UIViewController!

    override func setUp() {
        super.setUp()
        
        sut = UIViewController()
    }
    
    func testUILabelTruncation() {
        let label = UILabel(frame: CGRect(origin: .zero, size: .zero))
        label.text = "Some long text here"
        sut.view.addSubview(label)
        let lint = UILint(view: sut.view)
        print(lint!.findings)
        XCTAssertEqual(lint?.findings.count, 1)
        XCTAssertEqual(lint?.findings.first?.severity, .error)
        XCTAssertEqual(lint?.findings.first?.message, "Label is truncated")
    }
    
    func testDepth() {
        let v = UIView() // 0
        v.addSubview(UISlider()) // 3
        v.addSubview(UITableView()) // 4
        sut.view.addSubview(UIImageView()) // 1
        sut.view.addSubview(v) // 2
        sut.view.addSubview(UILabel()) // 5

        let lint = UILint(view: sut.view)
        XCTAssertEqual(lint?.elements.count, 6)
        XCTAssertEqual(lint?.elements[0].depth, 0)
        XCTAssertEqual(lint?.elements[1].depth, 1)
        XCTAssertEqual(lint?.elements[2].depth, 2)
        XCTAssertEqual(lint?.elements[3].depth, 3)
        XCTAssertEqual(lint?.elements[4].depth, 4)
        XCTAssertEqual(lint?.elements[5].depth, 5)
        
        XCTAssertEqual(lint?.elements[0].base.className, "UIView")
        XCTAssertEqual(lint?.elements[1].base.className, "UIImageView")
        XCTAssertEqual(lint?.elements[2].base.className, "UIView")
        XCTAssertEqual(lint?.elements[3].base.className, "UISlider")
        XCTAssertEqual(lint?.elements[4].base.className, "UITableView")
        XCTAssertEqual(lint?.elements[5].base.className, "UILabel")

    }

}
