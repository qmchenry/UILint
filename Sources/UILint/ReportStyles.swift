//
//  ReportStyles.swift
//  
//
//  Created by Quinn McHenry on 6/18/20.
//

import UIKit

extension Report {

    var largeTitleFont: UIFont { font(36) }
    var title1Font: UIFont { font(28) }
    var title2Font: UIFont { font(20) }
    var bodyFont: UIFont { font(12) }
    var caption1Font: UIFont { font(10) }

    func font(_ size: CGFloat) -> UIFont {
        if size > 30 {
            return UIFont(name: "Avenir-Black", size: size) ?? UIFont.systemFont(ofSize: size, weight: .regular)
        } else if size > 22 {
            return UIFont(name: "Avenir-Medium", size: size) ?? UIFont.systemFont(ofSize: size, weight: .regular)
        }
        return UIFont(name: "Avenir-Book", size: size) ?? UIFont.systemFont(ofSize: size, weight: .regular)
    }

    var title1: [NSAttributedString.Key: Any] {
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        return [NSAttributedString.Key.font: largeTitleFont,
                NSAttributedString.Key.paragraphStyle: style]
    }

    var title2: [NSAttributedString.Key: Any] {
        let style = NSMutableParagraphStyle()
        style.alignment = .left
        return [NSAttributedString.Key.font: title1Font,
                NSAttributedString.Key.paragraphStyle: style]
    }

    var title3: [NSAttributedString.Key: Any] {
        let style = NSMutableParagraphStyle()
        style.alignment = .left
        return [NSAttributedString.Key.font: title2Font,
                NSAttributedString.Key.paragraphStyle: style]
    }

    var body: [NSAttributedString.Key: Any] {
        let style = NSMutableParagraphStyle()
        style.alignment = .left
        style.lineBreakMode = .byWordWrapping
        return [NSAttributedString.Key.font: bodyFont,
                NSAttributedString.Key.paragraphStyle: style]
    }

    var unispacedBody: [NSAttributedString.Key: Any] {
        let style = NSMutableParagraphStyle()
        style.alignment = .left
        style.lineBreakMode = .byWordWrapping
        let font = UIFont(name: "Menlo-Regular", size: 12) ?? UIFont.systemFont(ofSize: 12, weight: .regular)
        return [NSAttributedString.Key.font: font,
                NSAttributedString.Key.paragraphStyle: style]
    }

    var detail: [NSAttributedString.Key: Any] {
        let style = NSMutableParagraphStyle()
        style.alignment = .left
        style.lineBreakMode = .byWordWrapping
        return [NSAttributedString.Key.font: caption1Font,
                NSAttributedString.Key.paragraphStyle: style]
    }

    var warning: [NSAttributedString.Key: Any] {
        let style = NSMutableParagraphStyle()
        style.alignment = .left
        return [NSAttributedString.Key.font: bodyFont,
                NSAttributedString.Key.foregroundColor: UIColor.black,
                NSAttributedString.Key.backgroundColor: UIColor.yellow,
                NSAttributedString.Key.paragraphStyle: style]
    }

    var error: [NSAttributedString.Key: Any] {
        let style = NSMutableParagraphStyle()
        style.alignment = .left
        return [NSAttributedString.Key.font: bodyFont,
                NSAttributedString.Key.foregroundColor: UIColor.white,
                NSAttributedString.Key.backgroundColor: UIColor.red,
                NSAttributedString.Key.paragraphStyle: style]
    }

    func style(severity: QAFindingSeverity) -> [NSAttributedString.Key: Any] {
        if case QAFindingSeverity.error = severity {
            return error
        }
        return warning
    }

    func color(severity: QAFindingSeverity) -> UIColor {
        if case QAFindingSeverity.error = severity {
            return UIColor.red
        }
        return UIColor.yellow
    }
}
