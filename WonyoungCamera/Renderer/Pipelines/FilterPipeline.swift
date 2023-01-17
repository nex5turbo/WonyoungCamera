//
//  FilterPipeline.swift
//  WonyoungCamera
//
//  Created by 워뇨옹 on 2023/01/10.
//

import Foundation
import MetalKit

class FilterPipeline {
    static let standardImageVertices: [Float] = [-1.0, 1.0, 1.0, 1.0, -1.0, -1.0, 1.0, -1.0]
    static let textureCoordinatesFill: [Float] = [0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 1.0, 1.0]
    var device: MTLDevice
    var library: MTLLibrary
    private var pipelineState: MTLRenderPipelineState?
    var standardImageVerticesBuffer: MTLBuffer?
    var texture0CoordinatesFillBuffer: MTLBuffer?
    var texture1CoordinatesFillBuffer: MTLBuffer?
    var addLayerBuffer1: [String: MTLBuffer]?
    var addLayerBuffer2: [String: MTLBuffer]?
    var addLayerBuffer3: [String: MTLBuffer]?
    var addLayerBuffer4: [String: MTLBuffer]?
    var addLayerBuffer5: [String: MTLBuffer]?
    var backgroundBuffer1: MTLBuffer?
    var backgroundBuffer2: MTLBuffer?
    var backgroundBuffer3: MTLBuffer?
    var brightnessBuffer: MTLBuffer?
    var contrastBuffer: MTLBuffer?
    var cropContentBuffer1: [String: MTLBuffer]?
    var cropContentBuffer2: MTLBuffer?
    var saturationBuffer: MTLBuffer?
    var filterBuffer: MTLBuffer?
    var sharpnessBuffer: MTLBuffer?
    var exposureBuffer: MTLBuffer?
    var vibranceBuffer: MTLBuffer?
    var whiteBalanceBuffer1: MTLBuffer?
    var whiteBalanceBuffer2: MTLBuffer?
    var vignetteBuffer: MTLBuffer?
    var grainBuffer: MTLBuffer?
    var highlightsAndShadowsBuffer1: MTLBuffer?
    var highlightsAndShadowsBuffer2: MTLBuffer?

    public init() {
        self.device = SharedMetalDevice.instance.device
        self.library = SharedMetalDevice.instance.defaultLibrary
    }
    func getRenderPipelineState() -> MTLRenderPipelineState? {
        if let pipelineState = pipelineState {
            return pipelineState
        }
        pipelineState = makeRenderPipelineState()
        return pipelineState
    }
    func makeRenderPipelineState() -> MTLRenderPipelineState? {
        // ABSTRACT: MUST IMPLEMENT
        fatalError("Abstract Method: MUST implement makeRenderPipelineState()")
    }
    func makeRenderPipelineState(vertexFunctionName: String, fragmentFunctionName: String) -> MTLRenderPipelineState? {
        let vertexProgram = library.makeFunction(name: vertexFunctionName)
        let fragmentProgram = library.makeFunction(name: fragmentFunctionName)

        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineDescriptor.vertexFunction = vertexProgram
        renderPipelineDescriptor.fragmentFunction = fragmentProgram
//        renderPipelineDescriptor.rasterSampleCount = self.sampleCount
//        renderPipelineDescriptor.isRasterizationEnabled = true
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        renderPipelineDescriptor.depthAttachmentPixelFormat = self.depthPixelFormat

        let renderPipelineState: MTLRenderPipelineState
        do {
            var reflection: MTLAutoreleasedRenderPipelineReflection?
            renderPipelineState = try device.makeRenderPipelineState(descriptor: renderPipelineDescriptor,
                                                                     options: [.bufferTypeInfo, .argumentInfo],
                                                                     reflection: &reflection)
        } catch {
            print("Could not makeRenderPipelineState - ")
            fatalError("vertexFunctionName: \(vertexFunctionName), fragmentFunctionName: \(fragmentFunctionName)")
        }
        return renderPipelineState
    }
    func renderPassDescriptor(_ texture: MTLTexture) -> MTLRenderPassDescriptor {
        // make renderPassDescriptor
        let renderPass = MTLRenderPassDescriptor()
        renderPass.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 0)
        renderPass.colorAttachments[0].loadAction = .clear
        if sampleCount > 1 {
            renderPass.colorAttachments[0].resolveTexture = texture
            renderPass.colorAttachments[0].texture = self.msaaTexture(width: texture.width, height: texture.height)
            renderPass.colorAttachments[0].storeAction = .storeAndMultisampleResolve
        } else {
            renderPass.colorAttachments[0].texture = texture
            renderPass.colorAttachments[0].storeAction = .store
        }
        if depthPixelFormat != .invalid {
            renderPass.depthAttachment.texture = self.depthTexture(width: texture.width, height: texture.height)
            renderPass.depthAttachment.loadAction = .clear
            renderPass.depthAttachment.storeAction = .dontCare
            renderPass.depthAttachment.clearDepth = 1.0
        }
        return renderPass
    }
    func makeRenderCommandEncoder(on commandBuffer: MTLCommandBuffer,
                                  to outputTexture: MTLTexture,
                                  using renderPassDescriptor: MTLRenderPassDescriptor? = nil)
                                                                        -> MTLRenderCommandEncoder? {
        guard let pipelineState = getRenderPipelineState() else {
            fatalError("Could not getRenderPipelineState")
        }
        // TODO: consider makeComputeCommandEncoder to compute
        let descriptor = renderPassDescriptor != nil ? renderPassDescriptor! : self.renderPassDescriptor(outputTexture)
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
            fatalError("Could not create render encoder")
        }
        renderEncoder.setFrontFacing(.counterClockwise)
        renderEncoder.setRenderPipelineState(pipelineState)
        return renderEncoder
    }
    // MARK: - MSAA
    // 1이 넘으면 MSAA, 4로 하기를 바람
    // https://developer.apple.com/documentation/metal/mtldevice/1433355-supportstexturesamplecount
    var sampleCount: Int = 1 // disabled
    private var msaaTexture: MTLTexture?
    private func msaaTexture(width: Int, height: Int) -> MTLTexture {
        if let texture = msaaTexture, texture.width == width && texture.height == height {
            return texture
        }
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: .bgra8Unorm,
            width: width,
            height: height,
            mipmapped: false
        )
        textureDescriptor.textureType = .type2DMultisample
        textureDescriptor.sampleCount = self.sampleCount
        textureDescriptor.usage = [.renderTarget]
        textureDescriptor.storageMode = .private
        guard let texture = device.makeTexture(descriptor: textureDescriptor) else {
            fatalError("Could not make a msaa texture: \(textureDescriptor)")
        }
        msaaTexture = texture
        return texture
    }
    // MARK: - depth
    var depthPixelFormat: MTLPixelFormat = .invalid // disabled // .depth32Float
    private var depthTexture: MTLTexture?
    private func depthTexture(width: Int, height: Int) -> MTLTexture {
        if let texture = depthTexture, texture.width == width && texture.height == height {
            return texture
        }
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: depthPixelFormat,
                                                                         width: width, height: height, mipmapped: false)
        textureDescriptor.textureType = self.sampleCount > 1 ? .type2DMultisample : .type2D
        textureDescriptor.sampleCount = self.sampleCount
        textureDescriptor.usage = [.renderTarget]
//        textureDescriptor.storageMode = .private
        guard let texture = device.makeTexture(descriptor: textureDescriptor) else {
            fatalError("Could not make a msaa texture: \(textureDescriptor)")
        }
        depthTexture = texture
        return texture
    }
    // MARK: - make buffers
    func makeBuffer(floatBytes: [Float], _ label: String? = nil) -> MTLBuffer {
        guard let buffer = device.makeBuffer(bytes: floatBytes,
                                             length: floatBytes.count * MemoryLayout<Float>.size, options: []) else {
            fatalError("Could not make floatBytes buffer")
        }
        buffer.label = label
        return buffer
    }
    func makeBuffer(intBytes: [Int], _ label: String? = nil) -> MTLBuffer {
        guard let buffer = device.makeBuffer(bytes: intBytes,
                                             length: intBytes.count * MemoryLayout<Int>.size, options: []) else {
            fatalError("Could not make intBytes buffer")
        }
        buffer.label = label
        return buffer
    }
    func makeBuffer(simdInt1: simd_int1, _ label: String? = nil) -> MTLBuffer {
        var valueBuffer = simdInt1
        guard let bufferCreated = device.makeBuffer(length: MemoryLayout<simd_int1>.size, options: []) else {
            fatalError("Could not create simd_int1 buffer")
        }
        let bufferPointer = bufferCreated.contents()
        memcpy(bufferPointer, &valueBuffer, MemoryLayout<simd_int1>.size)
        bufferCreated.label = label
        return bufferCreated
    }
    func makeBuffer(simdInt2: simd_int2, _ label: String? = nil) -> MTLBuffer {
        var valueBuffer = simdInt2
        guard let bufferCreated = device.makeBuffer(length: MemoryLayout<simd_int2>.size, options: []) else {
            fatalError("Could not create simd_int2 buffer")
        }
        let bufferPointer = bufferCreated.contents()
        memcpy(bufferPointer, &valueBuffer, MemoryLayout<simd_int2>.size)
        bufferCreated.label = label
        return bufferCreated
    }
    func makeBuffer(simdInt4: simd_int4, _ label: String? = nil) -> MTLBuffer {
        var valueBuffer = simdInt4
        guard let bufferCreated = device.makeBuffer(length: MemoryLayout<simd_int4>.size, options: []) else {
            fatalError("Could not create simd_int4 buffer")
        }
        let bufferPointer = bufferCreated.contents()
        memcpy(bufferPointer, &valueBuffer, MemoryLayout<simd_int4>.size)
        bufferCreated.label = label
        return bufferCreated
    }
    func makeBuffer(simdFloat2: simd_float2, _ label: String? = nil) -> MTLBuffer {
        var valueBuffer = simdFloat2
        guard let bufferCreated = device.makeBuffer(length: MemoryLayout<simd_float2>.size, options: []) else {
            fatalError("Could not create simd_float2 buffer")
        }
        let bufferPointer = bufferCreated.contents()
        memcpy(bufferPointer, &valueBuffer, MemoryLayout<simd_float2>.size)
        bufferCreated.label = label
        return bufferCreated
    }
    func makeBuffer(simdFloat4: simd_float4, _ label: String? = nil) -> MTLBuffer {
        var valueBuffer = simdFloat4
        guard let bufferCreated = device.makeBuffer(length: MemoryLayout<simd_float4>.size, options: []) else {
            fatalError("Could not create simd_float4 buffer")
        }
        let bufferPointer = bufferCreated.contents()
        memcpy(bufferPointer, &valueBuffer, MemoryLayout<simd_float4>.size)
        bufferCreated.label = label
        return bufferCreated
    }
//    func makeBuffer(simdHalf4: simd_half4, _ label: String? = nil) -> MTLBuffer {
//        var valueBuffer = simdHalf4
//        guard let bufferCreated = device.makeBuffer(length: MemoryLayout<simd_half4>.size, options: []) else {
//            fatalError("Could not create simd_half4 buffer")
//        }
//        let bufferPointer = bufferCreated.contents()
//        memcpy(bufferPointer, &valueBuffer, MemoryLayout<simd_half4>.size)
//        bufferCreated.label = label
//        return bufferCreated
//    }
    func makeBuffer(float: Float, _ label: String? = nil) -> MTLBuffer {
        var valueBuffer = float
        guard let bufferCreated = device.makeBuffer(length: MemoryLayout<Float>.size, options: []) else {
            fatalError("Could not create Float buffer")
        }
        let bufferPointer = bufferCreated.contents()
        memcpy(bufferPointer, &valueBuffer, MemoryLayout<Float>.size)
        bufferCreated.label = label
        return bufferCreated
    }
    func makeBuffer(color: UIColor, _ label: String? = nil) -> MTLBuffer {
        return makeBuffer(simdFloat4: color.toSimdFloat4())
    }
    func frameFloatBytes(transform: CGAffineTransform) -> [Float] {
        let leftTop = CGPoint(x: 0, y: 0)
        let rightTop = CGPoint(x: 1, y: 0)
        let leftBottom = CGPoint(x: 0, y: 1)
        let rightBottom = CGPoint(x: 1, y: 1)
        let leftTop1 = leftTop.applying(transform)
        let rightTop1 = rightTop.applying(transform)
        let leftBottom1 = leftBottom.applying(transform)
        let rightBottom1 = rightBottom.applying(transform)
        return [
            Float(leftTop1.x), Float(leftTop1.y),
            Float(rightTop1.x), Float(rightTop1.y),
            Float(leftBottom1.x), Float(leftBottom1.y),
            Float(rightBottom1.x), Float(rightBottom1.y)
        ]
    }
}

// MARK: - maths
extension FilterPipeline {
    func deg2rad(degree: Int) -> Float {
        return Float(degree) * .pi / 180.0
    }
    func rotated(xCoord: Float, yCoord: Float, radians: Float) -> (Float, Float) {
        return (
            cos(radians) * xCoord - sin(radians) * yCoord,
            sin(radians) * xCoord + cos(radians) * yCoord
        )
    }
    func rotated(xCoord: Float, yCoord: Float, radians: Float, anchorX: Float, anchorY: Float) -> (Float, Float) {
        let rotation = rotated(xCoord: xCoord - anchorX, yCoord: yCoord - anchorY, radians: radians)
        return (rotation.0 + anchorX, rotation.1 + anchorY)
    }

}

extension UIColor {
    func toSimdFloat4() -> simd_float4 {
        var fRed: CGFloat = 0
        var fGreen: CGFloat = 0
        var fBlue: CGFloat = 0
        var fAlpha: CGFloat = 0
        getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha)
        return [simd_float1(fRed), simd_float1(fGreen), simd_float1(fBlue), simd_float1(fAlpha)]
    }
}
