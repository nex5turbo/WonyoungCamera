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
    var backgroundImage: UIImage? {
        didSet {
            guard let backgroundImage else {
                return
            }
            backgroundTexture = BackgroundsStorage.instance.getTexture(backgroundImage)
            haveToBlur = false
            background = nil
        }
    }
    var background: String? {
        didSet {
            guard let background else {
                return
            }
            guard let texture = BackgroundsStorage.instance.getTexture(background) else {
                return
            }
            backgroundTexture = texture
            haveToBlur = false
            backgroundImage = nil
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
    var haveToBlur: Bool = false
    
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
