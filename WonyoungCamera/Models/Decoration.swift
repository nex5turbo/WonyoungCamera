//
//  Decoration.swift
//  WonyoungCamera
//
//  Created by Wonyoung Jang on 2023/01/06.
//

import UIKit
import Metal
import Foundation

struct Decoration {
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
    var borderColor: CodableColor?

    var scale: Float
    var positionX: Float
    var positionY: Float
    
    init(
        sticker: String?,
        background: String?,
        scale: Float,
        x: Float = 0.0,
        y: Float = 0.0
    ) {
        self.sticker = sticker
        self.background = background
        self.scale = scale
        self.positionX = x
        self.positionY = y
    }

    static func empty() -> Self {
        return Decoration(
            sticker: nil,
            background: nil,
            scale: 1.0
        )
    }
}
