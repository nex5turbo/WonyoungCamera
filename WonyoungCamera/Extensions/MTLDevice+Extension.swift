//
//  MTLDevice+Extension.swift
//  WonyoungCamera
//
//  Created by 워뇨옹 on 2023/01/25.
//

import MetalKit

extension MTLDevice {
    func loadImage(path: String) -> MTLTexture? {
        let textureLoader = MTKTextureLoader(device: self)
        if let url = URL(string: "file://\(path)") {
            let returnTexture = try? textureLoader.newTexture(URL: url, options: [.SRGB: false])
            return returnTexture
        }
        return nil
    }
    func loadImage(imageName: String, ext: String = "png") -> MTLTexture? {
        let textureLoader = MTKTextureLoader(device: self)
        if let url = Bundle.main.url(forResource: imageName, withExtension: ext) {
            let returnTexture = try? textureLoader.newTexture(URL: url, options: [.SRGB: false])
            return returnTexture
        }
        return nil
    }
    
    func loadFilter(filterName: String, ext: String = "png") -> MTLTexture? {
        let textureLoader = MTKTextureLoader(device: self)
        if let url = Bundle.main.url(forResource: filterName, withExtension: ext) {
            let returnTexture = try? textureLoader.newTexture(URL: url, options: [.SRGB: false])
            return returnTexture
        }
        return nil
    }
    func loadComputePipelineState(_ functionName: String = "roundingImage") -> MTLComputePipelineState? {
        let bundle = Bundle.main
        guard let url = bundle.url(forResource: "default", withExtension: "metallib") else { return nil }
        guard let library = try? self.makeLibrary(URL: url) else {
            return nil
        }
        guard let function = library.makeFunction(name: functionName) else { return nil }
        
        guard let returnValue = try? self.makeComputePipelineState(function: function) else {
            return nil
        }
        
        return returnValue
    }
    func makeTexture(image: UIImage?) -> MTLTexture? {
        guard let image = image, let cgImage = image.cgImage else {
            print("RSRenderer makeTexture(_) Error: The image is nil!")
            return nil
        }

        let textureLoader = MTKTextureLoader(device: self)
        let texture = try? textureLoader.newTexture(cgImage: cgImage, options: [.SRGB: false])
        return texture
    }
}
