//
//  LabelOverlap.swift
//  
//
//  Created by Quinn McHenry on 6/8/20.
//

import UIKit

public struct LabelOverlap: QACheck {
    public let description = "Labels overlap."

    public func findings(forElement element: QAElement,
                         elements: [QAElement],
                         windowSize: CGSize,
                         screenshot: UIImage?) -> [QAFinding] {
        guard element.isLabel else { return [] }
        let findings = elements.filter { $0.isLabel && $0.depth > element.depth }
            .compactMap { compareElement -> QAFinding? in
            // considering only depths > self's depth prevents duplication of findings as they both
            // overlap each other and also checking against self
            if element.overlaps(compareElement) {
                let unionBounds = element.base.windowFrame!.union(compareElement.base.windowFrame!)
                let croppedScreenshot = screenshot?.crop(to: unionBounds, viewSize: screenshot!.size)
                let message = "\(description)\n\(compareElement.base.className)[\(compareElement.depth)] overlaps "
                    + "\(element.base.className)[\(element.depth)] "
                let finding = QAFinding(message: message, severity: .warning,
                                        screenshot: croppedScreenshot, element: element)
                return finding
            }
            return nil
        }
        return findings
    }

    public init() {}
}
