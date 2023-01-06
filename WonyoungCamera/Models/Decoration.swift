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
            brightness: 1.0,
            saturation: 1.0,
            contrast: 1.0,
            scale: 1.0
        )
    }

    mutating public func setAdjustment(_ value: Float, to type: AdjustType) {
        switch type {
        case .brightness:
            brightness = 0.5 + (value / 100)
        case .contrast:
            contrast = 0.5 + (value / 100)
        case .saturation:
            saturation = 0.5 + (value / 100)
        }
    }
    
    public func getAdjustment(of type: AdjustType) -> Float {
        switch type {
        case .brightness:
            return (brightness - 0.5) * 100
        case .contrast:
            return (contrast - 0.5) * 100
        case .saturation:
            return (saturation - 0.5) * 100
        }
    }
}
