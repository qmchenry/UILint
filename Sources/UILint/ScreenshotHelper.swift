//
//  ScreenshotHelper.swift
//  DesignQA
//
//  Created by Quinn McHenry on 5/19/20.
//  Copyright © 2020 Quinn McHenry. All rights reserved.
//
// Adapted from code in https://github.com/nalexn/EnvironmentOverrides

// Usage:
// image = ScreenshotHelper.makeSnapshot()

import UIKit

struct ScreenshotHelper {
    static func takeScreenshot() -> UIImage {
        // Note: possibly not supported in macos/catalyst
        let view = UIScreen.main.snapshotView(afterScreenUpdates: false)
        let renderer = UIGraphicsImageRenderer(size: view.bounds.size)
        let image = renderer.image { _ in
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: false)
        }
        return image
    }
}

extension UIView {
    func takeScreenshot() -> UIImage {
        // Note: possibly not supported in macos/catalyst
        let renderer = UIGraphicsImageRenderer(size: bounds.size)
        let image = renderer.image { _ in
            drawHierarchy(in: bounds, afterScreenUpdates: false)
        }
        return image
    }
}
