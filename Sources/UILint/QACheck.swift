//
//  QACheck.swift
//  
//
//  Created by Quinn McHenry on 6/7/20.
//

import UIKit

public protocol QACheck {
    init()
    var description: String { get }
    func findings(forElement element: QAElement,
                  elements: [QAElement],
                  windowSize: CGSize,
                  screenshot: UIImage?) -> [QAFinding]
    func cropped(screenshot: UIImage?, toWindowFrame frame: CGRect?) -> UIImage?
}

public let allChecks: [QACheck.Type] = [
    LabelTruncation.self,
    LabelVerticalClipping.self,
    MinimumTapSizeCheck.self,
    OverlappingTouchBlockCheck.self
]

extension QACheck {

    public func cropped(screenshot: UIImage?, toWindowFrame frame: CGRect?) -> UIImage? {
        guard let screenshot = screenshot, let frame = frame else { return nil }
        return screenshot.crop(to: frame, viewSize: screenshot.size)
    }

}
