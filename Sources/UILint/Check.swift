//
//  QACheck.swift
//  
//
//  Created by Quinn McHenry on 6/7/20.
//

import UIKit

public protocol Check {
    init()
    var description: String { get }
    func findings(forElement element: Element,
                  elements: [Element],
                  details: EnvironmentDetails) -> [Finding]
    func crop(screenshot: UIImage?, toWindowFrame frame: CGRect?) -> UIImage?
}

public let allChecks: [Check.Type] = [
    LabelOffscreen.self,
    LabelOverlap.self,
    LabelTruncation.self,
    LabelUnexpectedFont.self,
    LabelVerticalClipping.self,
    MinimumTapSize.self,
    OverlappingTouchBlock.self,
    SafeArea.self
]

extension Check {

    public func crop(screenshot: UIImage?, toWindowFrame frame: CGRect?) -> UIImage? {
        guard let screenshot = screenshot, let frame = frame else { return nil }
        return screenshot.crop(to: frame, viewSize: screenshot.size)
    }

}
