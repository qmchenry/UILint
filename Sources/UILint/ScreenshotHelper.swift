//
//  ScreenshotHelper.swift
//  DesignQA
//
//  Created by Quinn McHenry on 5/19/20.
//  Copyright © 2020 Quinn McHenry. All rights reserved.
//

// Lovingly copied and pasted from https://stackoverflow.com/questions/25448879/how-do-i-take-a-full-screen-screenshot-in-swift

// Usage:
// image = UIApplication.shared.makeSnapshot()
// image = view.makeSnapshot()
// image = view.layer.makeSnapshot()
// image = UIImage(snapshotOf: view)

import UIKit

extension UIApplication {

    func getKeyWindow() -> UIWindow? {
        if #available(iOS 13, *) {
            return windows.first { $0.isKeyWindow } ?? windows.first
        }
        return keyWindow
    }

    func makeSnapshot() -> UIImage? {
        getKeyWindow()?.layer.makeSnapshot()
    }
}


extension CALayer {
    func makeSnapshot() -> UIImage? {
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(frame.size, false, scale)
        defer { UIGraphicsEndImageContext() }
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        render(in: context)
        let screenshot = UIGraphicsGetImageFromCurrentImageContext()
        return screenshot
    }
}

extension UIView {
    func makeSnapshot() -> UIImage? {
        if #available(iOS 10.0, *) {
            let renderer = UIGraphicsImageRenderer(size: frame.size)
            return renderer.image { _ in drawHierarchy(in: bounds, afterScreenUpdates: true) }
        } else {
            return layer.makeSnapshot()
        }
    }
}

extension UIImage {
    convenience init?(snapshotOf view: UIView) {
        guard let image = view.makeSnapshot(), let cgImage = image.cgImage else { return nil }
        self.init(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
    }
}
