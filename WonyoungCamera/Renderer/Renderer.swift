//
//  Renderer.swift
//  PhotoDiary
//
//  Created by 워뇨옹 on 2022/08/17.
//

import Foundation
import Metal
import UIKit
import MetalKit
import CoreMedia

class Renderer {
    private var device: MTLDevice
    private var deviceSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    private var deviceScale = UIScreen.main.scale
    private var provider = RenderableProvider()
    private var textureCache: CVMetalTextureCache?
    var targetTexture: MTLTexture?
    var cameraTexture: MTLTexture?
    var circleTexture: MTLTexture
    var computePipelineState: MTLComputePipelineState
    var filterPipelineState: MTLComputePipelineState
    var roundingPipelineState: MTLComputePipelineState?
    var defaultRenderPipelineState: MTLRenderPipelineState!
    var defaultLibrary: MTLLibrary
    var commandQueue: MTLCommandQueue
    
    let watermarkPipeline = WatermarkPipeline()
    let whiteBalancePipeline = WhiteBalancePipeline()
    let backgroundPipeline = BackgroundPipeline()
    
    init() {
        self.device = SharedMetalDevice.instance.device
        self.defaultLibrary = SharedMetalDevice.instance.defaultLibrary
        guard let commandQueue = device.makeCommandQueue() else {
            fatalError("[Error] No command queue for device: \(device)")
        }
        self.commandQueue = commandQueue
        guard let computePipelineState = device.loadComputePipelineState("roundingImage") else {
            fatalError()
        }
        guard let filterPipelineState = device.loadComputePipelineState("applyColorFilter") else {
            fatalError()
        }
        guard let circleTexture = device.loadFilter(filterName: "circle") else {
            fatalError()
        }
        self.circleTexture = circleTexture
        self.computePipelineState = computePipelineState
        self.filterPipelineState = filterPipelineState
        let defaultVertexProgram = defaultLibrary.makeFunction(name: "default_vertex")
        let defaultFragmentProgram = defaultLibrary.makeFunction(name: "default_fragment")
        let defaultRenderPipelineDesc = MTLRenderPipelineDescriptor()
        defaultRenderPipelineDesc.vertexFunction = defaultVertexProgram
        defaultRenderPipelineDesc.fragmentFunction = defaultFragmentProgram
        defaultRenderPipelineDesc.colorAttachments[0].pixelFormat = .bgra8Unorm
        // Alpha Blending
        defaultRenderPipelineDesc.colorAttachments[0].isBlendingEnabled = true
        defaultRenderPipelineDesc.colorAttachments[0].rgbBlendOperation = .add
        defaultRenderPipelineDesc.colorAttachments[0].alphaBlendOperation = .add
        defaultRenderPipelineDesc.colorAttachments[0].sourceRGBBlendFactor =  .sourceAlpha
        defaultRenderPipelineDesc.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
        defaultRenderPipelineDesc.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
        defaultRenderPipelineDesc.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha

        do {
            defaultRenderPipelineState = try device.makeRenderPipelineState(descriptor: defaultRenderPipelineDesc)
        } catch {
            fatalError("Engine Error: Cannot create defaultRenderPipelineState!")
        }
        if kCVReturnSuccess != CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, device, nil, &textureCache) {
            print("[Error] CVMetalTextureCacheCreate")
        }
    }
    
    public func makeTexture(descriptor: MTLTextureDescriptor) -> MTLTexture? {
        return device.makeTexture(descriptor: descriptor)
    }
    
    public func makeEmptyTexture(size: CGSize) -> MTLTexture? {
        let textureDescriptor = MTLTextureDescriptor()
        textureDescriptor.textureType = .type2D
        textureDescriptor.pixelFormat = .bgra8Unorm
        textureDescriptor.width = Int(size.width)
        textureDescriptor.height = Int(size.height)
        textureDescriptor.usage = [.shaderRead, .shaderWrite, .renderTarget]
        return makeTexture(descriptor: textureDescriptor)
    }
    
    func makeRenderPassDescriptor(texture: MTLTexture, clearColor: Bool) -> MTLRenderPassDescriptor {
        let renderPassDescriptor = MTLRenderPassDescriptor()

        if clearColor {
            renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(
                red: 0 / 255.0,
                green: 0 / 255.0,
                blue: 0 / 255.0,
                alpha: 1
            )
            renderPassDescriptor.colorAttachments[0].loadAction = .clear
        } else {
            renderPassDescriptor.colorAttachments[0].loadAction = .load
        }
        renderPassDescriptor.colorAttachments[0].texture = texture
        return renderPassDescriptor
    }

    func applyLut(
        on commandBuffer: MTLCommandBuffer,
        to outputTexture: MTLTexture,
        from inputTexture: MTLTexture,
        lutTexture: MTLTexture
    ) {

        var textureWidth = Float(inputTexture.width)
        var textureHeight = Float(inputTexture.height)

        // compute
        let computeEncoder = commandBuffer.makeComputeCommandEncoder()
        computeEncoder?.setComputePipelineState(self.filterPipelineState)
        computeEncoder?.setTexture(outputTexture, index: 0)
        computeEncoder?.setTexture(inputTexture, index: 1)
        computeEncoder?.setTexture(lutTexture, index: 2)
        
        computeEncoder?.setBytes(&textureWidth, length: MemoryLayout<Float>.stride, index: 1)
        computeEncoder?.setBytes(&textureHeight, length: MemoryLayout<Float>.stride, index: 2)
        let w = computePipelineState.threadExecutionWidth
        let h = computePipelineState.maxTotalThreadsPerThreadgroup / w
        let threadsPerThreadgroup = MTLSizeMake(w, h, 1)

        let threadgroupsPerGrid = MTLSizeMake((outputTexture.width + w - 1) / w,
                                         (outputTexture.height + h - 1) / h,
                                         1)
        computeEncoder?.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)

        computeEncoder?.endEncoding()
    }

    func applyLut(to inputTexture: MTLTexture, lutTexture: MTLTexture) -> MTLTexture? {
        guard let commandBuffer = commandQueue.makeCommandBuffer() else {
            print("[Error] no commandBuffer for commandQueue: \(commandQueue)")
            return nil
        }
        let textureDescriptor = MTLTextureDescriptor()
        textureDescriptor.textureType = .type2D
        textureDescriptor.pixelFormat = .bgra8Unorm
        textureDescriptor.width = inputTexture.width
        textureDescriptor.height = inputTexture.height
        textureDescriptor.usage = [.shaderRead, .shaderWrite, .renderTarget]
        guard let returnTexture = self.makeTexture(descriptor: textureDescriptor) else {
            return nil
        }
        applyLut(
            on: commandBuffer,
            to: returnTexture,
            from: inputTexture,
            lutTexture: lutTexture
        )
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
        return returnTexture
    }
    
    func applyLutToSampleImage(_ sampleImageTexture: MTLTexture, lutTexture: MTLTexture) -> UIImage? {
        guard let resultTexture = applyLut(to: sampleImageTexture, lutTexture: lutTexture) else {
            return nil
        }
        return textureToUIImage(texture: resultTexture)
    }

    func render(
        on commandBuffer: MTLCommandBuffer,
        to outputTexture: MTLTexture,
        with inputTexture: MTLTexture,
        decoration: Decoration
    ) {
        let quadVertices = getVertices()
        let vertices = device.makeBuffer(bytes: quadVertices, length: MemoryLayout<Vertex>.size * quadVertices.count, options: [])
        let numVertice = quadVertices.count
        
        //draw primitive
        let renderPassDescriptor = makeRenderPassDescriptor(texture: outputTexture, clearColor: true)
        guard let renderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return }
        renderCommandEncoder.setRenderPipelineState(self.defaultRenderPipelineState)
        renderCommandEncoder.setVertexBuffer(vertices, offset: 0, index: 0)
        renderCommandEncoder.setFragmentTexture(targetTexture, index: 0)

        var textureWidth: Float = Float(outputTexture.width)
        renderCommandEncoder.setFragmentBytes(&textureWidth, length: MemoryLayout<Float>.stride, index: 0)
        var textureHeight: Float = Float(outputTexture.height)
        renderCommandEncoder.setFragmentBytes(&textureHeight, length: MemoryLayout<Float>.stride, index: 1)
        renderCommandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: numVertice)
        renderCommandEncoder.endEncoding()
    }

    func render(
        to drawable: CAMetalDrawable,
        with pixelBuffer: CVPixelBuffer?,
        decoration: Decoration
    ) {
        let texture = pixelBufferToTexture(pixelBuffer)
        render(to: drawable, with: texture, decoration: decoration)
    }
    
    func render(
        to drawable: CAMetalDrawable,
        with texture: MTLTexture?,
        decoration: Decoration
    ) {
        guard let commandBuffer = commandQueue.makeCommandBuffer() else {
            print("[Error] no commandBuffer for commandQueue: \(commandQueue)")
            return
        }

        guard let texture = texture else {
            return
        }
        guard let targetTexture,
                min(texture.width, texture.height) ==
                min(targetTexture.width, targetTexture.height) else {
            let targetLength = Int(min(texture.width, texture.height))
            let targetSize = CGSize(width: targetLength, height: targetLength)
            self.targetTexture = self.makeEmptyTexture(size: targetSize)
            return
        }
        guard let cameraTexture,
              cameraTexture.width == texture.width,
              cameraTexture.height == texture.height else {
            let targetSize = CGSize(width: texture.width, height: texture.height)
            self.cameraTexture = self.makeEmptyTexture(size: targetSize)
            return
        }

        applyBackground(
            decoration: decoration,
            on: commandBuffer,
            to: targetTexture
        )
        applyColorFilter(
            decoration: decoration,
            on: commandBuffer,
            to: cameraTexture,
            with: texture
        )
        
        roundingImage(
            decoration: decoration,
            on: commandBuffer,
            to: targetTexture,
            with: cameraTexture
        )
//        applySticker(
//            decoration: decoration,
//            on: commandBuffer,
//            to: targetTexture
//        )

        render(on: commandBuffer, to: drawable.texture, with: targetTexture, decoration: decoration)
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }

    func getVertices() -> [Vertex] {
        let returnValue = [
            Vertex(position: SIMD2<Float>(1, -1), textureCoordinate: SIMD2<Float>(1,1)),
            Vertex(position: SIMD2<Float>(-1, -1), textureCoordinate: SIMD2<Float>(0,1)),
            Vertex(position: SIMD2<Float>(-1, 1), textureCoordinate: SIMD2<Float>(0,0)),

            Vertex(position: SIMD2<Float>(1, -1), textureCoordinate: SIMD2<Float>(1,1)),
            Vertex(position: SIMD2<Float>(-1, 1), textureCoordinate: SIMD2<Float>(0,0)),
            Vertex(position: SIMD2<Float>(1, 1), textureCoordinate: SIMD2<Float>(1,0))
        ]
        return returnValue
    }
}

// MARK: apply functions
extension Renderer {
    func applyBackground(
        decoration: Decoration,
        on commandBuffer: MTLCommandBuffer,
        to outputTexture: MTLTexture
    ) {
        guard let backgroundTexture = decoration.backgroundTexture else {
            return
        }
        backgroundPipeline.render(from: backgroundTexture, to: outputTexture, commandBuffer: commandBuffer)
    }

    func applySticker(
        decoration: Decoration,
        on commandBuffer: MTLCommandBuffer,
        to outputTexture: MTLTexture
    ) {
//        let renderable = provider.getRenderableOrFetch(decoration.sticker)
//        guard let texture = renderable?.getCurrentTexture(on: device) else { return }
    }

    func roundingImage(
        decoration: Decoration,
        on commandBuffer: MTLCommandBuffer,
        to outputTexture: MTLTexture,
        with inputTexture: MTLTexture
    ) {
        // MARK: - This should be changed with fragment shader
        var scale = decoration.scale
        var borderWidth = decoration.borderThickness
        var borderColor = SIMD4<Float>(0, 0, 0, 0)
        if let color = decoration.borderColor {
            borderColor = SIMD4<Float>(
                Float(color.red),
                Float(color.green),
                Float(color.blue),
                Float(color.alpha)
            )
        }
        var hasBackground = decoration.backgroundTexture != nil
        var hasBorder = decoration.borderColor != nil
        // compute
        let computeEncoder = commandBuffer.makeComputeCommandEncoder()
        computeEncoder?.setComputePipelineState(self.computePipelineState)
        computeEncoder?.setTexture(outputTexture, index: 0)
        computeEncoder?.setTexture(inputTexture, index: 1)
        computeEncoder?.setTexture(circleTexture, index: 2)
        
        computeEncoder?.setBytes(&scale, length: MemoryLayout<Float>.stride, index: 0)
        computeEncoder?.setBytes(&borderWidth, length: MemoryLayout<Float>.stride, index: 1)
        computeEncoder?.setBytes(&borderColor, length: MemoryLayout<SIMD4<Float>>.stride, index: 2)
        computeEncoder?.setBytes(&hasBackground, length: MemoryLayout<Bool>.stride, index: 3)
        computeEncoder?.setBytes(&hasBorder, length: MemoryLayout<Bool>.stride, index: 4)
        
        let w = computePipelineState.threadExecutionWidth
        let h = computePipelineState.maxTotalThreadsPerThreadgroup / w
        let threadsPerThreadgroup = MTLSizeMake(w, h, 1)

        let threadgroupsPerGrid = MTLSizeMake((outputTexture.width + w - 1) / w,
                                         (outputTexture.height + h - 1) / h,
                                         1)
        computeEncoder?.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)

        computeEncoder?.endEncoding()
    }

    func applyColorFilter(
        decoration: Decoration,
        on commandBuffer: MTLCommandBuffer,
        to outputTexture: MTLTexture,
        with inputTexture: MTLTexture
    ) {
        guard let filterTexture = LutStorage.instance.luts[decoration.colorFilter] else {
            return
        }
        /**
         RAW Processing: Convert the raw image file into a usable format, such as TIFF or JPEG, and make basic adjustments, such as white balance and exposure.
         
         Cropping and Straightening: Crop the image to the desired aspect ratio and straighten the image if necessary.
         
         Adjusting Tonality: Adjust the overall brightness, contrast, and mid-tones of the image.
         
         Color Correction: Adjust the hue, saturation, and luminance of specific colors in the image.
         
         Sharpening: Increase the clarity and definition of the image's edges and details.
         
         Noise Reduction: Reduce image noise, which can be introduced by shooting in low light conditions or using high ISO settings.
         
         Spot Removal: Remove any distracting spots, blemishes, or dust from the image.
         
         Local Adjustments: Make specific adjustments to certain areas of the image, such as dodging and burning, selective color correction, or local sharpening.
         
         Export: Save the final image in the desired format and quality.

         */
        applyLut(
            on: commandBuffer,
            to: outputTexture,
            from: inputTexture,
            lutTexture: filterTexture
        )
        whiteBalancePipeline.render(
            whiteBalanceProperties: WhiteBalanceProperties(
                tint: 0,
                temperature: decoration.whiteBalance.currentValue
            ),
            from: outputTexture,
            to: outputTexture,
            commandBuffer: commandBuffer
        )
        ExposurePipeline().render(
            exposure: decoration.exposure.currentValue,
            from: outputTexture,
            to: outputTexture,
            commandBuffer: commandBuffer
        )
        ContrastPipeline().render(
            contrast: decoration.contrast.currentValue,
            from: outputTexture,
            to: outputTexture,
            commandBuffer: commandBuffer
        )
//        BrightnessPipeline().render(
//            brightness: decoration.brightness.currentValue,
//            from: outputTexture,
//            to: outputTexture,
//            commandBuffer: commandBuffer
//        )
        SaturationPipeline().render(
            saturation: decoration.saturation.currentValue,
            from: outputTexture,
            to: outputTexture,
            commandBuffer: commandBuffer
        )
    }
}

extension Renderer {
    func roundingImage(
        with texture: MTLTexture,
        decoration: Decoration
    ) -> MTLTexture? {
        let targetLength = min(texture.width, texture.height)
        let targetSize = CGSize(width: targetLength, height: targetLength)
        guard let outputTexture = self.makeEmptyTexture(size: targetSize) else { return nil }
        guard let emptyTexture = self.makeEmptyTexture(size: CGSize(width: texture.width, height: texture.height)) else { return nil }
        guard let commandBuffer = self.commandQueue.makeCommandBuffer() else { return nil }
        applyColorFilter(decoration: decoration, on: commandBuffer, to: emptyTexture, with: texture)
        roundingImage(decoration: decoration, on: commandBuffer, to: outputTexture, with: emptyTexture)
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
        return outputTexture
    }
    
    func roundingImage(
        with pixelBuffer: CVPixelBuffer,
        decoration: Decoration
    ) -> MTLTexture? {
        guard let texture = pixelBufferToTexture(pixelBuffer) else {
            return nil
        }
        return roundingImage(with: texture, decoration: decoration)
    }
    
    func roundingImage(
        with sampleBuffer: CMSampleBuffer,
        decoration: Decoration
    ) -> MTLTexture? {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return nil
        }
        return roundingImage(with: pixelBuffer, decoration: decoration)
    }
}

extension Renderer {
    func pixelBufferToTexture(_ pixelBuffer: CVPixelBuffer?) -> MTLTexture? {
        guard let pixelBuffer else { return nil }
        CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: CVOptionFlags(0)))

        guard self.textureCache != nil else {
            return nil
        }

        // Create a Metal texture from the image buffer
        var cvTextureOut: CVMetalTexture?
        CVMetalTextureCacheCreateTextureFromImage(
            kCFAllocatorDefault,
            textureCache!,
            pixelBuffer,
            nil,
            .bgra8Unorm,
            CVPixelBufferGetWidth(pixelBuffer),
            CVPixelBufferGetHeight(pixelBuffer),
            0,
            &cvTextureOut
        )

        guard let cvTexture = cvTextureOut else {
            CVMetalTextureCacheFlush(textureCache!, 0)
            CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: CVOptionFlags(0)))
            #if DEBUG
            fatalError("NO cvMetalTexture - makeTextureFromSampleBuffer")
            #else
            return nil
            #endif
        }
        guard let texture = CVMetalTextureGetTexture(cvTexture) else {
            CVMetalTextureCacheFlush(textureCache!, 0)
            CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: CVOptionFlags(0)))
            #if DEBUG
            fatalError("NO texture - makeTextureFromSampleBuffer")
            #else
            return nil
            #endif
        }

        defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: CVOptionFlags(0))) }
        return texture
    }
}

struct Vertex {
    var position: SIMD2<Float>
    var textureCoordinate: SIMD2<Float>
}

extension Renderer {
    func captureCirclePhoto(of sampleBuffer: CMSampleBuffer, decoration: Decoration) -> UIImage? {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return nil
        }
        guard let texture = pixelBufferToTexture(pixelBuffer) else {
            return nil
        }
        guard let commandBuffer = commandQueue.makeCommandBuffer() else {
            return nil
        }
        let targetLength = Int(min(texture.width, texture.height))
        let targetSize = CGSize(width: targetLength, height: targetLength)
        guard let squareTexture = self.makeEmptyTexture(size: targetSize) else {
            return nil
        }
        let originalSize = CGSize(width: texture.width, height: texture.height)
        guard let originalTexture = self.makeEmptyTexture(size: originalSize) else {
            return nil
        }
        applyBackground(
            decoration: decoration,
            on: commandBuffer,
            to: squareTexture
        )
        applyColorFilter(
            decoration: decoration,
            on: commandBuffer,
            to: originalTexture,
            with: texture
        )
        
        roundingImage(
            decoration: decoration,
            on: commandBuffer,
            to: squareTexture,
            with: originalTexture
        )
        if !UserSettings.instance.removeWatermark {
            watermarkPipeline.render(from: squareTexture, to: squareTexture, commandBuffer: commandBuffer)
        }
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
        return textureToUIImage(texture: squareTexture)
    }
    func captureOriginalPhoto(of sampleBuffer: CMSampleBuffer, decoration: Decoration) -> UIImage? {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return nil
        }
        guard let texture = pixelBufferToTexture(pixelBuffer) else {
            return nil
        }
        guard let commandBuffer = commandQueue.makeCommandBuffer() else {
            return nil
        }
        let originalSize = CGSize(width: texture.width, height: texture.height)
        guard let originalTexture = self.makeEmptyTexture(size: originalSize) else {
            return nil
        }
        applyColorFilter(
            decoration: decoration,
            on: commandBuffer,
            to: originalTexture,
            with: texture
        )
        if !UserSettings.instance.removeWatermark {
            watermarkPipeline.render(from: originalTexture, to: originalTexture, commandBuffer: commandBuffer)
        }
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
        return textureToUIImage(texture: originalTexture)
    }
}
