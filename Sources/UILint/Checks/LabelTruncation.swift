//
//  LabelTruncation.swift
//  
//
//  Created by Quinn McHenry on 6/8/20.
//

import UIKit

public struct LabelTruncation: QACheck {
    public let description = "Label text is truncated."

    public func findings(forElement element: QAElement,
                         elements: [QAElement],
                         windowSize: CGSize,
                         screenshot: UIImage?) -> [QAFinding] {
        guard element.isLabelTruncated() else { return [] }
        // todo handle auto font scaling

        let message = "\(description)\n\(element.base.className) full text is '\(element.labelText ?? "")' "
        let croppedScreenshot = cropped(screenshot: screenshot, toWindowFrame: element.base.windowFrame)

        let finding = QAFinding(message: message, severity: .error,
                                screenshot: croppedScreenshot, element: element)
        return [finding]
    }

    public init() {}
}
