//
//  SharpnessPipeline.swift
//  WonyoungCamera
//
//  Created by 워뇨옹 on 2023/01/17.
//

import MetalKit

class SharpnessPipeline: FilterPipeline {
    override func makeRenderPipelineState() -> MTLRenderPipelineState? {
        return makeRenderPipelineState(vertexFunctionName: "oneInputVertex", fragmentFunctionName: "sharpenFragment")
    }
    public func render(sharpness: Float, from sourceTexture: MTLTexture,
                       to outputTexture: MTLTexture, commandBuffer: MTLCommandBuffer) {
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
        if sharpnessBuffer == nil {
            sharpnessBuffer = makeBuffer(float: sharpness)
        } else {
            var valueBuffer = sharpness
            memcpy(sharpnessBuffer?.contents(), &valueBuffer, MemoryLayout<Float>.size)
        }
        renderEncoder.setFragmentBuffer(sharpnessBuffer, offset: 0, index: 0)
        // draw
        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        renderEncoder.endEncoding()
    }
}
