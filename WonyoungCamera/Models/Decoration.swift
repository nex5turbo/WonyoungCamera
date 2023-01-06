//
//  Decoration.swift
//  WonyoungCamera
//
//  Created by Wonyoung Jang on 2023/01/06.
//

import UIKit
import Foundation

struct Decoration {
    var colorFilter: Lut
    var sticker: String?
    var background: String?
    
    var border: Bool
    var borderColor: UIColor?
    
    var brightness: Float
    var saturation: Float
    var contrast: Float
    var scale: Float
    
    init(
        colorFilter: Lut,
        sticker: String?,
        background: String?,
        border: Bool,
        borderColor: UIColor?,
        brightness: Float,
        saturation: Float,
        contrast: Float,
        scale: Float
    ) {
        self.colorFilter = colorFilter
        self.sticker = sticker
        self.background = background
        self.border = border
        self.borderColor = borderColor
        self.brightness = brightness
        self.saturation = saturation
        self.contrast = contrast
        self.scale = scale
    }

    static func empty() -> Self {
        return Decoration(
            colorFilter: .Natural,
            sticker: nil,
            background: nil,
            border: false,
            borderColor: nil,
            brightness: 0.5,
            saturation: 0.5,
            contrast: 0.5,
            scale: 1
        )
    }
}
