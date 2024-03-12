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
    var frame: String? {
        didSet {
            guard let frame else {
                frameTexture = nil
                return
            }
            guard let texture = FramesStorage.instance.getTexture(frame) else {
                return
            }
            frameTexture = texture
        }
    }
    var frameTexture: MTLTexture?
    var backgroundTexture: MTLTexture?
    
    var borderThickness: Float = 0.5 // 0 ~ 1, 0.5 default
    var borderColor: CodableColor?

    var scale: Float
    var positionX: Float
    var positionY: Float
    
    init(
        background: String?,
        frame: String?,
        scale: Float,
        x: Float = 0.0,
        y: Float = 0.0
    ) {
        self.background = background
        self.scale = scale
        self.frame = frame
        self.positionX = x
        self.positionY = y
    }

    static func empty() -> Self {
        return Decoration(
            background: nil,
            frame: nil,
            scale: 1.0
        )
    }
}
