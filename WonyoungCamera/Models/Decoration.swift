//
//  Decoration.swift
//  WonyoungCamera
//
//  Created by Wonyoung Jang on 2023/01/06.
//

import UIKit
import Foundation

enum AdjustType {
    case brightness, contrast, saturation, whiteBalance
}

struct Decoration {
    var colorFilter: Lut
    var sticker: String?
    var background: String?
    
    var borderThickness: Float = 0.5 // 0 ~ 1, 0.1 default
    var borderColor: CodableColor = .init(uiColor: .black)
    
    var brightness: Float
    var saturation: Float
    var contrast: Float
    var whiteBalance: Float
/**
 var sharpness: Float
 var highlights: Float
 var shadows: Float
 var exposure: Float
  whiteBalance
 var vibrance: Float
  vignette -> Array
 var grain: Float
*/
    var scale: Float
    
    init(
        colorFilter: Lut,
        sticker: String?,
        background: String?,
        brightness: Float,
        saturation: Float,
        contrast: Float,
        scale: Float,
        whiteBalance: Float
    ) {
        self.colorFilter = colorFilter
        self.sticker = sticker
        self.background = background
        self.brightness = brightness
        self.saturation = saturation
        self.contrast = contrast
        self.scale = scale
        self.whiteBalance = whiteBalance
    }

    static func empty() -> Self {
        return Decoration(
            colorFilter: .Natural,
            sticker: nil,
            background: nil,
            brightness: 1.0,
            saturation: 1.0,
            contrast: 1.0,
            scale: 1.0,
            whiteBalance: 0.5
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
        case .whiteBalance:
            whiteBalance = (value / 100)
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
        case .whiteBalance:
            return (whiteBalance) * 100
        }
    }
}
/**
    Contrast -> Float
    Sharpness -> Float
    Highlights, shadows -> Float, Float
    Exposure -> Float
    White Balance -> WhiteBalanceProperties(Float, Float)
    Vibrance -> Float
    Vignette -> struct VignetteUniform {
            let vignetteCenter: simd_float2
            let vignetteColor: simd_float3
            let vignetteStart: Float
            let vignetteEnd: Float
            let vignettePercent: Float
            init(vignettePercent: Float,
                 vignetteCenter: simd_float2 = simd_float2(x: 0.5, y: 0.5),
                 vignetteColor: simd_float3 = simd_float3(repeating: 0),
                 vignetteStart: Float = 0.3,
                 vignetteEnd: Float = 0.75) {
                self.vignettePercent = vignettePercent
                self.vignetteCenter = vignetteCenter
                self.vignetteColor = vignetteColor
                self.vignetteStart = vignetteStart
                self.vignetteEnd = vignetteEnd
            }
        }

    Grain -> Float
    Gray scale -> Not
    Saturation -> Float
    Brightness -> Float
*/
