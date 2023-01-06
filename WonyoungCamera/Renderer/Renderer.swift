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
    var frameTexture: MTLTexture?
    var circleTexture: MTLTexture
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
        guard let circleTexture = device.loadFilter(filterName: "circle") else {
            fatalError()
        }
        self.circleTexture = circleTexture
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
        if compute == "roundingImage" {
            self.frameTexture = device.loadFilter(filterName: "cameraFrame")
        }
    }
    public func makeTexture(descriptor: MTLTextureDescriptor) -> MTLTexture? {
        return device.makeTexture(descriptor: descriptor)
    }
    func makeRenderPassDescriptor(texture: MTLTexture, clearColor: Bool) -> MTLRenderPassDescriptor {
        let renderPassDescriptor = MTLRenderPassDescriptor()

        if clearColor {
            renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(
                red: 1,
                green: 1,
                blue: 1,
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
        let textureDescriptor = MTLTextureDescriptor()
        textureDescriptor.textureType = .type2D
        textureDescriptor.pixelFormat = .bgra8Unorm
        textureDescriptor.width = texture.width
        textureDescriptor.height = texture.height
        textureDescriptor.usage = [.shaderRead, .shaderWrite, .renderTarget]
        guard let returnTexture = self.makeTexture(descriptor: textureDescriptor) else {
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
        decoration: Decoration
    ) {
        guard let commandBuffer = commandQueue.makeCommandBuffer() else {
            print("[Error] no commandBuffer for commandQueue: \(commandQueue)")
            return
        }

        guard let texture = texture else {
            return
        }
        var textureWidth = Float(texture.width)
        var textureHeight = Float(texture.height)
        if emptyTexture == nil {
            let size = Int(min(textureWidth, textureHeight))
            let textureDescriptor = MTLTextureDescriptor()
            textureDescriptor.textureType = .type2D
            textureDescriptor.pixelFormat = .bgra8Unorm
            textureDescriptor.width = size
            textureDescriptor.height = size
            textureDescriptor.usage = [.shaderRead, .shaderWrite, .renderTarget]
            guard let newTexture = self.makeTexture(descriptor: textureDescriptor) else {
                fatalError()
            }
            self.emptyTexture = newTexture
        }
        guard let emptyTexture = self.emptyTexture else {
            return
        }

        var lutTexture = LutStorage.instance.luts[LutStorage.instance.selectedLut]
        if LutStorage.instance.selectedLut == .Natural {
            lutTexture = nil
        }
        var shouldFilter = lutTexture != nil
        let quadVertices = getVertices()
        let vertices = device.makeBuffer(bytes: quadVertices, length: MemoryLayout<Vertex>.size * quadVertices.count, options: [])
        let numVertice = quadVertices.count
        
        var scale = decoration.scale
        var border = decoration.border
        
        var brightness = decoration.brightness
        var contrast = decoration.contrast
        var saturation = decoration.saturation
        // compute
        let computeEncoder = commandBuffer.makeComputeCommandEncoder()
        computeEncoder?.setComputePipelineState(self.computePipelineState)
        computeEncoder?.setTexture(emptyTexture, index: 0)
        computeEncoder?.setTexture(texture, index: 1)
        computeEncoder?.setTexture(lutTexture, index: 2)
        computeEncoder?.setTexture(circleTexture, index: 3)
        
        computeEncoder?.setBytes(&textureWidth, length: MemoryLayout<Float>.stride, index: 0)
        computeEncoder?.setBytes(&textureHeight, length: MemoryLayout<Float>.stride, index: 1)
        computeEncoder?.setBytes(&shouldFilter, length: MemoryLayout<Bool>.stride, index: 2)
        computeEncoder?.setBytes(&scale, length: MemoryLayout<Float>.stride, index: 3)
        computeEncoder?.setBytes(&brightness, length: MemoryLayout<Float>.stride, index: 4)
        computeEncoder?.setBytes(&contrast, length: MemoryLayout<Float>.stride, index: 5)
        computeEncoder?.setBytes(&saturation, length: MemoryLayout<Float>.stride, index: 6)
        computeEncoder?.setBytes(&border, length: MemoryLayout<Bool>.stride, index: 7)
        
        let w = computePipelineState.threadExecutionWidth
        let h = computePipelineState.maxTotalThreadsPerThreadgroup / w
        let threadsPerThreadgroup = MTLSizeMake(w, h, 1)

        let threadgroupsPerGrid = MTLSizeMake((emptyTexture.width + w - 1) / w,
                                         (emptyTexture.height + h - 1) / h,
                                         1)
        computeEncoder?.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)

        computeEncoder?.endEncoding()
        //draw primitive
        let renderPassDescriptor = makeRenderPassDescriptor(texture: drawable.texture, clearColor: true)
        guard let renderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return }
        renderCommandEncoder.setRenderPipelineState(self.defaultRenderPipelineState)
        renderCommandEncoder.setVertexBuffer(vertices, offset: 0, index: 0)
        renderCommandEncoder.setFragmentTexture(emptyTexture, index: 0)
        renderCommandEncoder.setFragmentTexture(frameTexture, index: 1)

        var drawableWidth: Float = Float(drawable.texture.width)
        renderCommandEncoder.setFragmentBytes(&drawableWidth, length: MemoryLayout<Float>.stride, index: 0)
        var drawableHeight: Float = Float(drawable.texture.height)
        renderCommandEncoder.setFragmentBytes(&drawableHeight, length: MemoryLayout<Float>.stride, index: 1)
        var deviceScale = UIScreen.main.scale
        renderCommandEncoder.setFragmentBytes(&deviceScale, length: MemoryLayout<Float>.stride, index: 2)
        renderCommandEncoder.setFragmentBytes(&shouldFilter, length: MemoryLayout<Bool>.stride, index: 3)
        renderCommandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: numVertice)
        renderCommandEncoder.endEncoding()
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

struct Vertex {
    var position: SIMD2<Float>
    var textureCoordinate: SIMD2<Float>
}

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
        guard let image = image else {
            print("RSRenderer makeTexture(_) Error: The image is nil!")
            return nil
        }

        let textureLoader = MTKTextureLoader(device: self)
        let texture = try! textureLoader.newTexture(cgImage: image.cgImage!)
        return texture
    }
}
