import XCTest
@testable import UILint

final class UILintTests: XCTestCase {
    
    var sut: UIViewController!

    override func setUp() {
        super.setUp()
        
        sut = UIViewController()
    }
    
    func testExample() {
        let label = UILabel(frame: CGRect(origin: .zero, size: .zero))
        sut.view.addSubview(label)
        UILint.lint(view: sut.view)
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
