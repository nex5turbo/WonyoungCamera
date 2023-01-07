//
//  Renderable.swift
//  WonyoungCamera
//
//  Created by 워뇨옹 on 2023/01/07.
//

import Foundation
import UIKit
import MetalKit

class Renderable {
    var texture: MTLTexture?
    init() {
        
    }
    func getCurrentTexture(on device: MTLDevice) -> MTLTexture? {
        abort()
    }
    func finish() {
        abort()
    }
}

class ImageRenderable: Renderable {
    var image: UIImage

    init(image: UIImage) {
        self.image = image
        super.init()
    }

    override func getCurrentTexture(on device: MTLDevice) -> MTLTexture? {
        return cachedImageTexture(on: device)
    }
    
    func cachedImageTexture(on device: MTLDevice) -> MTLTexture? {
        if texture != nil {
            return texture
        }

        texture = self.getTexture(image: image, on: device)
        return texture
    }

    private func getTexture(image: UIImage, on device: MTLDevice) -> MTLTexture {
        guard let data = image.pngData() else {
            fatalError("No data")
        }
        let textureLoader = MTKTextureLoader(device: device)
        do {
            return try textureLoader.newTexture(data: data, options: [MTKTextureLoader.Option.SRGB: false])
        } catch {
            fatalError("Error textureLoader.newTexture - Exception")
        }
    }
    override func finish() {
        self.texture = nil
    }
}
