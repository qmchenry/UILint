//
//  LabelOverlap.swift
//  
//
//  Created by Quinn McHenry on 6/8/20.
//

import UIKit

public struct LabelOverlap: Check {
    public let description = "Labels overlap."

    public func findings(forElement element: Element, elements: [Element], details: EnvironmentDetails) -> [Finding] {
        guard element.isLabel else { return [] }
        let findings = elements.filter { $0.isLabel && $0.depth > element.depth }
            .compactMap { compareElement -> Finding? in
            // considering only depths > self's depth prevents duplication of findings as they both
            // overlap each other and also checking against self
            if element.overlaps(compareElement) {
                let unionBounds = element.base.windowFrame!.union(compareElement.base.windowFrame!)
                let cropped = details.screenshot?.crop(to: unionBounds, viewSize: details.screenshot!.size)
                let explanation = "\(compareElement.base.className) [\(compareElement.depth)] overlaps "
                    + "\(element.base.className) [\(element.depth)] "
                let finding = Finding(description: description, explanation: explanation, severity: .error,
                                      screenshot: cropped, element: element)
                return finding
            }
            return nil
        }
        return findings
    }

    public init() {}
}
