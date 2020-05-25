import XCTest
@testable import UILint

final class UILintTests: XCTestCase {
    
    var sut: UIViewController!

    override func setUp() {
        super.setUp()
        
        sut = UIViewController()
    }
    
    func testUILabel() {
        let label = UILabel(frame: CGRect(origin: .zero, size: .zero))
        sut.view.addSubview(label)
        UILint.lint(view: sut.view)
    }
    
    func testZPositions() {
        func zView(_ zPosition: CGFloat) -> UIView {
            let view = UIView()
            view.layer.zPosition = zPosition
            return view
        }
        sut.view.addSubview(UIImageView()) // zPosition 0
        sut.view.addSubview(UILabel()) // zPosition 0
        sut.view.addSubview(zView(3))
        sut.view.addSubview(zView(-1))
        
        UILint.lint(view: sut.view)
    }

}
