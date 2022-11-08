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
}
let cancelLabel = NSLocalizedString("Cancel", comment: "")
let stickerLabel = NSLocalizedString("Sticker", comment: "")
let selectLabel = NSLocalizedString("Select", comment: "")
let askDeleteLabel = NSLocalizedString("delete?", comment: "")
let deleteLabel = NSLocalizedString("delete", comment: "")
let shareLabel = NSLocalizedString("share", comment: "")

func selectedCountText(c1: Int, c2: Int) -> String {
    let countedLabel = String(format: NSLocalizedString("%d / %d selected", comment: ""), c1, c2)
    //let countLabel = NSLocalizedString("%d / %d Selected", comment: "")
    return countedLabel
}

