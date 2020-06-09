//
//  MinimumTapSizeCheck.swift
//  
//
//  Created by Quinn McHenry on 6/8/20.
//

import UIKit

public struct MinimumTapSize: QACheck {
    public let description = "Provide ample touch targets for interactive elements."

    public func findings(forElement element: QAElement,
                         elements: [QAElement],
                         windowSize: CGSize,
                         screenshot: UIImage?) -> [QAFinding] {
        guard element.base.wantsTouches, let windowFrame = element.base.windowFrame else { return [] }
        guard windowFrame.size.height < 44 || windowFrame.size.width < 44 else { return [] }

        let cropped = screenshot?.crop(to: windowFrame, viewSize: screenshot!.size)
        let message = "\(description)\n\(element.base.className) width/height is "
                      + "less than 44pt (\(windowFrame.width),\(windowFrame.height))"
        let finding = QAFinding(message: message, severity: .error, screenshot: cropped, element: element)
        return [finding]
    }

    public init() {}
}
