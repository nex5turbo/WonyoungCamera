//
//  Decoration.swift
//  WonyoungCamera
//
//  Created by Wonyoung Jang on 2023/01/06.
//

import UIKit
import Metal
import Foundation

protocol Adjustment {
    var range: ClosedRange<Float> { get }
    var defaultValue: Float { get }
    var currentValue: Float { get set }
    var presentFactor: Float { get }
    var presentValue: String { get }
    var type: AdjustType { get }
    mutating func reset()
}

extension Adjustment {
    mutating func reset() {
        self.currentValue = defaultValue
    }
    var presentValue: String {
        return String(format: "%.2f", currentValue * presentFactor)
    }
}

//struct Brightness: Adjustment {
//    var range: ClosedRange<Float> = 0...2
//    var defaultValue: Float = 1
//    var currentValue: Float = 1
//    var presentFactor: Float = 50
//    var type: AdjustType = .brightness
//}

struct Contrast: Adjustment {
    var range: ClosedRange<Float> = 0...2.5
    var defaultValue: Float = 1.25
    var type: AdjustType = .contrast
    var presentFactor: Float = 40
    var currentValue: Float = 1.25
}

struct Saturation: Adjustment {
    var range: ClosedRange<Float> = 0...2.5
    var defaultValue: Float = 1.25
    var type: AdjustType = .saturation
    var presentFactor: Float = 40
    var currentValue: Float = 1.25
}

struct WhiteBalance: Adjustment {
    var range: ClosedRange<Float> = 0...1.2
    var defaultValue: Float = 0.6
    var type: AdjustType = .whiteBalance
    var presentFactor: Float = 100 / 1.2
    var currentValue: Float = 0.6
}

struct Exposure: Adjustment {
    var range: ClosedRange<Float> = -1...1
    var defaultValue: Float = 0
    var type: AdjustType = .exposure
    var presentFactor: Float = 1
    var currentValue: Float = 0
}

enum AdjustType {
    case exposure
//    case brightness
    case contrast
    case saturation
    case whiteBalance
    func getIconName() -> String {
        switch self {
        case .exposure:
            return "sun.max.circle"
//            return "circle.righthalf.filled"
//        case .brightness:
//            return "sun.max.circle"
        case .contrast:
            return "circle.righthalf.filled"
        case .saturation:
            return "drop.circle.fill"
        case .whiteBalance:
            return "thermometer.sun.circle"
        }
    }
}

struct Decoration {
    var colorFilter: Lut
    var sticker: String?
    var background: String? {
        didSet {
            guard let background else {
                backgroundTexture = nil
                return
            }
            guard let texture = BackgroundsStorage.instance.getTexture(background) else {
                return
            }
            backgroundTexture = texture
        }
    }
    var backgroundTexture: MTLTexture?
    
    var borderThickness: Float = 0.5 // 0 ~ 1, 0.5 default
    var borderColor: CodableColor = .init(uiColor: .black)
    
//    var brightness: Brightness = Brightness()
    var saturation: Saturation = Saturation()
    var contrast: Contrast = Contrast()
    var whiteBalance: WhiteBalance = WhiteBalance()
    var exposure: Exposure = Exposure() // default 0, -1 ~ 1
    var selectedAdjustment: Adjustment
/**
 var sharpness: Float
 var highlights: Float
 var shadows: Float
 var vibrance: Float
  vignette -> Array
 var grain: Float
*/
    var scale: Float
    
    init(
        colorFilter: Lut,
        sticker: String?,
        background: String?,
        scale: Float
    ) {
        self.colorFilter = colorFilter
        self.sticker = sticker
        self.background = background
        self.scale = scale
        self.selectedAdjustment = exposure
    }

    static func empty() -> Self {
        return Decoration(
            colorFilter: .Natural,
            sticker: nil,
            background: nil,
            scale: 1.0
        )
    }
    mutating func switchAdjustment() {
        switch selectedAdjustment.type {
        case .exposure:
            self.selectedAdjustment = contrast
//        case .brightness:
//            self.selectedAdjustment = contrast
        case .contrast:
            self.selectedAdjustment = saturation
        case .saturation:
            self.selectedAdjustment = whiteBalance
        case .whiteBalance:
            self.selectedAdjustment = exposure
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
