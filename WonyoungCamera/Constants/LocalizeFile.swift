//
//  LocalizeFile.swift
//  WonyoungCamera
//
//  Created by 장진영 on 2022/11/08.
//

import Foundation

extension String {
    static let APP_NAME = "Rounder Camera"
    static let APP_NAME_SHORT = "Rounder"
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    static let cancelLabel = NSLocalizedString("Cancel", comment: "")
    static let subscribeLabel = NSLocalizedString("Subscribe", comment: "")
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
    static let noPhotoText = NSLocalizedString("No photo.", comment: "")
    static let sizeText = NSLocalizedString("297 x 210 (mm)", comment: "")
    static let shareInfoText = NSLocalizedString("Share info text", comment: "")
    static let mindText = NSLocalizedString("Round Your Mind", comment: "")
    static let byUsText = NSLocalizedString("By Rounder Camera", comment: "")
    static let monthlyPlanName = NSLocalizedString("Rounder monthly plan", comment: "")
    static let appreciateText = NSLocalizedString("Thanks for using Rounder Camera!", comment: "")
    static let priceText = NSLocalizedString("3-day free trial then $1.49/month", comment: "")
    static let tryAgainText = NSLocalizedString("Please try again.", comment: "")
    static let subscribeSuccessText = NSLocalizedString("Take your priceless moment!", comment: "")
    
    // SettingView
    static let saveOriginalLabel = NSLocalizedString("Save Original Photo", comment: "")
    static let hapticLabel = NSLocalizedString("Haptic", comment: "")
    static let settingLabel = NSLocalizedString("Settings", comment: "")
    static let aboutLabel = NSLocalizedString("About", comment: "")
    static let rateLabel = NSLocalizedString("Rate", comment: "")
    static let contactLabel = NSLocalizedString("Contact", comment: "")
    static let viewPermissionLabel = NSLocalizedString("View App Permissions", comment: "")
    static let removeWatermarkLabel = NSLocalizedString("Remove watermark for original photo", comment: "")
}


