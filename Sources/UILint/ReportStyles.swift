//
//  ReportStyles.swift
//  
//
//  Created by Quinn McHenry on 6/18/20.
//

import UIKit

extension Report {

    var title1: [NSAttributedString.Key: Any] {
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        return [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .largeTitle),
                NSAttributedString.Key.paragraphStyle: style]
    }

    var title2: [NSAttributedString.Key: Any] {
        let style = NSMutableParagraphStyle()
        style.alignment = .left
        return [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .title1),
                NSAttributedString.Key.paragraphStyle: style]
    }

    var title3: [NSAttributedString.Key: Any] {
        let style = NSMutableParagraphStyle()
        style.alignment = .left
        return [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .title2),
                NSAttributedString.Key.paragraphStyle: style]
    }

    var body: [NSAttributedString.Key: Any] {
        let style = NSMutableParagraphStyle()
        style.alignment = .left
        style.lineBreakMode = .byWordWrapping
        return [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body),
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
        return [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1),
                NSAttributedString.Key.paragraphStyle: style]
    }

    var warning: [NSAttributedString.Key: Any] {
        let style = NSMutableParagraphStyle()
        style.alignment = .left
        return [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body),
                NSAttributedString.Key.foregroundColor: UIColor.black,
                NSAttributedString.Key.backgroundColor: UIColor.yellow,
                NSAttributedString.Key.paragraphStyle: style]
    }

    var error: [NSAttributedString.Key: Any] {
        let style = NSMutableParagraphStyle()
        style.alignment = .left
        return [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body),
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
