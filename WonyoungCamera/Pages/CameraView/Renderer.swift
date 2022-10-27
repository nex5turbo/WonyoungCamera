//
//  Renderer.swift
//  PhotoDiary
//
//  Created by 워뇨옹 on 2022/08/17.
//

import Foundation
import Metal
import QuartzCore
import UIKit

class Renderer {
    private var device: MTLDevice
    private var deviceSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    private var deviceScale = UIScreen.main.scale
    var emptyTexture: MTLTexture?
    var computePipelineState: MTLComputePipelineState
    var defaultRenderPipelineState: MTLRenderPipelineState!
    var defaultLibrary: MTLLibrary
    var commandQueue: MTLCommandQueue
    init(compute: String = "roundingImage") {
        self.device = SharedMetalDevice.instance.device
        guard let commandQueue = device.makeCommandQueue() else {
            fatalError("[Error] No command queue for device: \(device)")
        }
        self.commandQueue = commandQueue
        guard let defaultLibrary = device.makeDefaultLibrary() else {
            fatalError("[Error] No command queue for device: \(device)")
        }
        guard let computePipelineState = device.loadComputePipelineState(compute) else {
            fatalError()
        }
        self.computePipelineState = computePipelineState
        self.defaultLibrary = defaultLibrary
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
    }
    public func makeTexture(descriptor: MTLTextureDescriptor) -> MTLTexture? {
        return device.makeTexture(descriptor: descriptor)
    }
    func makeRenderPassDescriptor(texture: MTLTexture, clearColor: Bool, color: (Int, Int, Int)) -> MTLRenderPassDescriptor {
        let renderPassDescriptor = MTLRenderPassDescriptor()

        if clearColor {
            renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(
                red: Double(color.0) / 255,
                green: Double(color.1) / 255,
                blue: Double(color.2) / 255,
                alpha: 1
            )
            renderPassDescriptor.colorAttachments[0].loadAction = .clear
        } else {
            renderPassDescriptor.colorAttachments[0].loadAction = .load
        }
        renderPassDescriptor.colorAttachments[0].texture = texture
        return renderPassDescriptor
    }
    func applyLutToSampleImage(_ sampleImageTexture: MTLTexture, lutTexture: MTLTexture) -> UIImage? {
        guard let commandBuffer = commandQueue.makeCommandBuffer() else {
            print("[Error] no commandBuffer for commandQueue: \(commandQueue)")
            return nil
        }
        let texture = sampleImageTexture
        guard let returnTexture = createTexture(width: texture.width, height: texture.height) else {
            return nil
        }

        var textureWidth = Float(texture.width)
        var textureHeight = Float(texture.height)

        // compute
        let computeEncoder = commandBuffer.makeComputeCommandEncoder()
        computeEncoder?.setComputePipelineState(self.computePipelineState)
        computeEncoder?.setTexture(returnTexture, index: 0)
        computeEncoder?.setTexture(texture, index: 1)
        computeEncoder?.setTexture(lutTexture, index: 2)
        
        computeEncoder?.setBytes(&textureWidth, length: MemoryLayout<Float>.stride, index: 1)
        computeEncoder?.setBytes(&textureHeight, length: MemoryLayout<Float>.stride, index: 2)
        let w = computePipelineState.threadExecutionWidth
        let h = computePipelineState.maxTotalThreadsPerThreadgroup / w
        let threadsPerThreadgroup = MTLSizeMake(w, h, 1)

        let threadgroupsPerGrid = MTLSizeMake((returnTexture.width + w - 1) / w,
                                         (returnTexture.height + h - 1) / h,
                                         1)
        computeEncoder?.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)

        computeEncoder?.endEncoding()
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
        return textureToUIImage(texture: returnTexture)
    }
    func render(
        to drawable: CAMetalDrawable,
        with texture: MTLTexture?,
        shouldFlip: Bool,
        size: Int = 1080,
        frameOffset: Float = 0.2,
        scale: Float = 1,
        brightness: Float = 0.0,
        contrast: Float = 0.0,
        saturation: Float = 0.0,
        clearColor: (Int, Int, Int) = (0, 0, 0)
    ) {
        guard let commandBuffer = commandQueue.makeCommandBuffer() else {
            print("[Error] no commandBuffer for commandQueue: \(commandQueue)")
            return
        }

        guard let texture = texture else {
            return
        }
        if emptyTexture == nil || min(texture.height, texture.width) != size {
            print("DEBUG4 switch \(emptyTexture == nil) \(min(texture.height, texture.width)) \(size)")
            guard let newTexture = createTexture(size: size) else {
                fatalError()
            }
            self.emptyTexture = newTexture
        }
        guard let emptyTexture = self.emptyTexture else {
            return
        }

        var lutTexture: MTLTexture? = nil
        if LutStorage.instance.selectedLut != nil {
            lutTexture = LutStorage.instance.luts[LutStorage.instance.selectedLut!]
        }
        var shouldFilter = lutTexture != nil
        let quadVertices = getVertices(frameOffset: frameOffset)
        let vertices = device.makeBuffer(bytes: quadVertices, length: MemoryLayout<Vertex>.size * quadVertices.count, options: [])
        let numVertice = quadVertices.count
        
        var shouldFlip = shouldFlip
        var deviceWidth = Float(deviceSize.width)
        var deviceHeight = Float(deviceSize.height)
        var deviceScale = Float(deviceScale)
        var textureWidth = Float(texture.width)
        var textureHeight = Float(texture.height)
        var brightness = brightness
        var contrast = contrast
        var saturation = saturation
        var scale = scale

        // compute
        let computeEncoder = commandBuffer.makeComputeCommandEncoder()
        computeEncoder?.setComputePipelineState(self.computePipelineState)
        computeEncoder?.setTexture(emptyTexture, index: 0)
        computeEncoder?.setTexture(texture, index: 1)
        computeEncoder?.setTexture(lutTexture, index: 2)
        
        computeEncoder?.setBytes(&shouldFlip, length: MemoryLayout<Bool>.stride, index: 0)
        computeEncoder?.setBytes(&textureWidth, length: MemoryLayout<Float>.stride, index: 1)
        computeEncoder?.setBytes(&textureHeight, length: MemoryLayout<Float>.stride, index: 2)
        computeEncoder?.setBytes(&shouldFilter, length: MemoryLayout<Bool>.stride, index: 3)
        computeEncoder?.setBytes(&scale, length: MemoryLayout<Float>.stride, index: 4)
        computeEncoder?.setBytes(&brightness, length: MemoryLayout<Float>.stride, index: 5)
        computeEncoder?.setBytes(&contrast, length: MemoryLayout<Float>.stride, index: 6)
        computeEncoder?.setBytes(&saturation, length: MemoryLayout<Float>.stride, index: 7)
        
        let w = computePipelineState.threadExecutionWidth
        let h = computePipelineState.maxTotalThreadsPerThreadgroup / w
        let threadsPerThreadgroup = MTLSizeMake(w, h, 1)

        let threadgroupsPerGrid = MTLSizeMake((emptyTexture.width + w - 1) / w,
                                         (emptyTexture.height + h - 1) / h,
                                         1)
        computeEncoder?.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)

        computeEncoder?.endEncoding()
        //draw primitive
        let renderPassDescriptor = makeRenderPassDescriptor(texture: drawable.texture, clearColor: true, color: clearColor)
        guard let renderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return }
        renderCommandEncoder.setRenderPipelineState(self.defaultRenderPipelineState)
        renderCommandEncoder.setVertexBuffer(vertices, offset: 0, index: 0)
        renderCommandEncoder.setFragmentTexture(emptyTexture, index: 0)
        renderCommandEncoder.setFragmentTexture(lutTexture, index: 1)
        renderCommandEncoder.setFragmentBytes(&shouldFlip, length: MemoryLayout<Bool>.stride, index: 0)
        renderCommandEncoder.setFragmentBytes(&deviceWidth, length: MemoryLayout<Float>.stride, index: 1)
        renderCommandEncoder.setFragmentBytes(&deviceHeight, length: MemoryLayout<Float>.stride, index: 2)
        renderCommandEncoder.setFragmentBytes(&deviceScale, length: MemoryLayout<Float>.stride, index: 3)
        renderCommandEncoder.setFragmentBytes(&shouldFilter, length: MemoryLayout<Bool>.stride, index: 4)
        renderCommandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: numVertice)
        renderCommandEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    private func createTexture(size: Int) -> MTLTexture? {
       let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(
         pixelFormat: MTLPixelFormat.rgba8Unorm,
         width: size,
         height: size,
         mipmapped: false)
       
       textureDescriptor.usage = [.shaderWrite, .shaderRead]
       
       guard let texture: MTLTexture = device.makeTexture(descriptor: textureDescriptor) else {
         return nil
       }
       
       let region = MTLRegion.init(origin: MTLOrigin.init(x: 0, y: 0, z: 0), size: MTLSize.init(width: texture.width, height: texture.height, depth: 1));
       
       let count = size * size * 4
       let stride = MemoryLayout<CChar>.stride
       let alignment = MemoryLayout<CChar>.alignment
       let byteCount = stride * count
       
       let p = UnsafeMutableRawPointer.allocate(byteCount: byteCount, alignment: alignment)
       let data = p.initializeMemory(as: CChar.self, repeating: 0, count: count)
         
       texture.replace(region: region, mipmapLevel: 0, withBytes: data, bytesPerRow: size * 4)
       
       return texture
     }
    private func createTexture(width: Int, height: Int) -> MTLTexture? {
       let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(
         pixelFormat: MTLPixelFormat.rgba8Unorm,
         width: width,
         height: height,
         mipmapped: false)
       
       textureDescriptor.usage = [.shaderWrite, .shaderRead]
       
       guard let texture: MTLTexture = device.makeTexture(descriptor: textureDescriptor) else {
         return nil
       }
       
       let region = MTLRegion.init(origin: MTLOrigin.init(x: 0, y: 0, z: 0), size: MTLSize.init(width: texture.width, height: texture.height, depth: 1));
       
       let count = width * height * 4
       let stride = MemoryLayout<CChar>.stride
       let alignment = MemoryLayout<CChar>.alignment
       let byteCount = stride * count
       
       let p = UnsafeMutableRawPointer.allocate(byteCount: byteCount, alignment: alignment)
       let data = p.initializeMemory(as: CChar.self, repeating: 0, count: count)
         
       texture.replace(region: region, mipmapLevel: 0, withBytes: data, bytesPerRow: width * 4)
       
       return texture
     }
    func getVertices(frameOffset: Float) -> [Vertex] {
        let ratio: Float = Float(UIScreen.main.bounds.width / UIScreen.main.bounds.height)
        let returnValue = [
            Vertex(position: SIMD2<Float>(1, frameOffset - ratio), textureCoordinate: SIMD2<Float>(1,1)),
            Vertex(position: SIMD2<Float>(-1, frameOffset - ratio), textureCoordinate: SIMD2<Float>(0,1)),
            Vertex(position: SIMD2<Float>(-1, frameOffset + ratio), textureCoordinate: SIMD2<Float>(0,0)),

            Vertex(position: SIMD2<Float>(1, frameOffset - ratio), textureCoordinate: SIMD2<Float>(1,1)),
            Vertex(position: SIMD2<Float>(-1, frameOffset + ratio), textureCoordinate: SIMD2<Float>(0,0)),
            Vertex(position: SIMD2<Float>(1, frameOffset + ratio), textureCoordinate: SIMD2<Float>(1,0))
        ]
        return returnValue
    }
    func textureToUIImage(texture: MTLTexture) -> UIImage? {
        guard let cgImage = convertToCGImage(texture: texture) else {
            return nil
        }
        let uiImage = UIImage(cgImage: cgImage)
        return uiImage
    }
}

struct Vertex {
    var position: SIMD2<Float>
    var textureCoordinate: SIMD2<Float>
}

import MetalKit
extension MTLDevice {
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
}
