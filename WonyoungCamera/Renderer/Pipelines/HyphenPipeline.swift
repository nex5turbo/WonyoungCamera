//
//  MTHefePipeline.swift
//  Imica
//
//  Created by 워뇨옹 on 2023/07/24.
//

import Foundation
import Metal

// TODO: Problem

class HyphenPipeline: FilterPipeline {
    override var name: String { return "Hyphen" }
    override func makeRenderPipelineState() -> MTLRenderPipelineState? {
        return makeRenderPipelineState(vertexFunctionName: "oneInputVertex", fragmentFunctionName: "MTHefeFragment")
    }
    override func render(from sourceTexture: MTLTexture,
                       to outputTexture: MTLTexture,
                       commandBuffer: MTLCommandBuffer) {
        guard let edgeBurn = samplerTexture(named: "edgeBurn.pvr") else {
            return
        }
        guard let gradMap = samplerTexture(named: "hefeGradientMap.png") else {
            return
        }
        guard let hefeMetal = samplerTexture(named: "hefeMetal.pvr") else {
            return
        }
        guard let map = samplerTexture(named: "hefeMap.png") else {
            return
        }
        guard let softLight = samplerTexture(named: "hefeSoftLight.png") else {
            return
        }
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
        renderEncoder.setFragmentTexture(edgeBurn, index: 1)
        renderEncoder.setFragmentTexture(gradMap, index: 2)
        renderEncoder.setFragmentTexture(hefeMetal, index: 3)
        renderEncoder.setFragmentTexture(map, index: 4)
        renderEncoder.setFragmentTexture(softLight, index: 5)
        var strength: Float = 1.0
        renderEncoder.setFragmentBytes(&strength, length: MemoryLayout<Float>.stride, index: 0)
        // draw
        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        renderEncoder.endEncoding()
    }
}
