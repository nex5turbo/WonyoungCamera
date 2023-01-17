//
//  VignettePipeline.swift
//  WonyoungCamera
//
//  Created by 워뇨옹 on 2023/01/17.
//

import MetalKit

class VignettePipeline: FilterPipeline {

    override func makeRenderPipelineState() -> MTLRenderPipelineState? {
        return makeRenderPipelineState(vertexFunctionName: "oneInputVertex", fragmentFunctionName: "vignetteFragment")
    }

    public func render(vignetteUniform: VignetteUniform,
                       from sourceTexture: MTLTexture,
                       to outputTexture: MTLTexture,
                       commandBuffer: MTLCommandBuffer) {
        guard let renderEncoder = makeRenderCommandEncoder(on: commandBuffer, to: outputTexture) else {
            fatalError("Could not make CommandEncoder")
        }

        // setup vertex buffer
        if standardImageVerticesBuffer == nil {
            standardImageVerticesBuffer = makeBuffer(floatBytes: FilterPipeline.standardImageVertices, "Vertices")
        }
        renderEncoder.setVertexBuffer(standardImageVerticesBuffer, offset: 0, index: 0)
        if texture0CoordinatesFillBuffer == nil {
            texture0CoordinatesFillBuffer = makeBuffer(floatBytes: FilterPipeline.textureCoordinatesFill,
                                                       "Texture 0 Coordinates")
        }
        renderEncoder.setVertexBuffer(texture0CoordinatesFillBuffer, offset: 0, index: 1) // the texture
        // setup fragment buffer
        renderEncoder.setFragmentTexture(sourceTexture, index: 0)
        if vignetteBuffer == nil {
            vignetteBuffer = makeBuffer(vignetteUniform: vignetteUniform)
        } else {
            var valueBuffer = vignetteUniform
            memcpy(vignetteBuffer?.contents(), &valueBuffer, MemoryLayout<VignetteUniform>.size)
        }
        renderEncoder.setFragmentBuffer(vignetteBuffer, offset: 0, index: 1)

        // draw
        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        renderEncoder.endEncoding()
    }
    struct VignetteUniform {
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
    func makeBuffer(vignetteUniform: VignetteUniform, _ label: String? = nil) -> MTLBuffer {
        var valueBuffer = vignetteUniform
        guard let bufferCreated = device.makeBuffer(length: MemoryLayout<VignetteUniform>.stride, options: []) else {
            fatalError("Could not create VignetteUniform buffer")
        }
        let bufferPointer = bufferCreated.contents()
        memcpy(bufferPointer, &valueBuffer, MemoryLayout<VignetteUniform>.size)
        bufferCreated.label = label
        return bufferCreated
    }
}
