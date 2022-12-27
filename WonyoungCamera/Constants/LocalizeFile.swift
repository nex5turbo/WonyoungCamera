//
//  LocalizeFile.swift
//  WonyoungCamera
//
//  Created by 장진영 on 2022/11/08.
//

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    static let cancelLabel = NSLocalizedString("Cancel", comment: "")
    static let stickerLabel = NSLocalizedString("Sticker", comment: "")
    static let selectLabel = NSLocalizedString("Select", comment: "")
    static let askDeleteLabel = NSLocalizedString("delete?", comment: "")
    static let deleteLabel = NSLocalizedString("delete", comment: "")
    static let shareLabel = NSLocalizedString("share", comment: "")
    static let appName = NSLocalizedString("appName", comment: "")
    static func selectedCountText(c1: Int, c2: Int) -> String {
        let countedLabel = String(format: NSLocalizedString("%d / %d selected", comment: ""), c1, c2)
        //let countLabel = NSLocalizedString("%d / %d Selected", comment: "")
        return countedLabel
    }
    static let subscriptionInfoText = NSLocalizedString("Subscribe information text", comment: "")
}


