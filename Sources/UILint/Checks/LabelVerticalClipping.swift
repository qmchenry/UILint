//
//  LabelVerticalClipping.swift
//  
//
//  Created by Quinn McHenry on 6/8/20.
//

import UIKit

public struct LabelVerticalClipping: Check {
    public let description = "Label is clipped vertically."

    public func findings(forElement element: Element,
                         elements: [Element],
                         windowSize: CGSize,
                         safeAreaRect: CGRect,
                         screenshot: UIImage?) -> [Finding] {
        guard element.isLabelClippedVertically() else { return [] }
        // todo handle auto font scaling

        let message = "\(description)\n\(element.base.className) full text is '\(element.labelText ?? "")' "
        let croppedScreenshot = cropped(screenshot: screenshot, toWindowFrame: element.base.windowFrame)

        let finding = Finding(message: message, severity: .error,
                                screenshot: croppedScreenshot, element: element)
        return [finding]
    }

    public init() {}
}
