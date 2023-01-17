//
//  HighlightsAndShadowsPipeline.swift
//  WonyoungCamera
//
//  Created by 워뇨옹 on 2023/01/17.
//

import MetalKit

class HighlightsAndShadowsPipeline: FilterPipeline {

    override func makeRenderPipelineState() -> MTLRenderPipelineState? {
        return makeRenderPipelineState(vertexFunctionName: "oneInputVertex",
                                       fragmentFunctionName: "highlightShadowFragment")
    }
    public func render(highlights: Float = 1.0, shadows: Float = 0.0, from sourceTexture: MTLTexture,
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
        if highlightsAndShadowsBuffer1 == nil {
            highlightsAndShadowsBuffer1 = makeBuffer(float: highlights + 0.5)
        } else {
            var valueBuffer = highlights + 0.5
            memcpy(highlightsAndShadowsBuffer1?.contents(), &valueBuffer, MemoryLayout<Float>.size)
        }
        renderEncoder.setFragmentBuffer(highlightsAndShadowsBuffer1, offset: 0, index: 0)
        if highlightsAndShadowsBuffer2 == nil {
            highlightsAndShadowsBuffer2 = makeBuffer(float: shadows - 0.5)
        } else {
            var valueBuffer = shadows - 0.5
            memcpy(highlightsAndShadowsBuffer2?.contents(), &valueBuffer, MemoryLayout<Float>.size)
        }
        renderEncoder.setFragmentBuffer(highlightsAndShadowsBuffer2, offset: 0, index: 1)
        // draw
        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        renderEncoder.endEncoding()
    }
}
