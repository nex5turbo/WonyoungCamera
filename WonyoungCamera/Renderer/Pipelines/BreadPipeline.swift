//
//  Temp6Pipeline.swift
//  Imica
//
//  Created by 워뇨옹 on 2023/09/09.
//

import Foundation
import Metal

class BreadPipeline: FilterPipeline {
    override var name: String { return "Bread" }
    override var sampleImageName: String { return .sampleGlassedCat }
    override func makeRenderPipelineState() -> MTLRenderPipelineState? {
        return makeRenderPipelineState(vertexFunctionName: "oneInputVertex", fragmentFunctionName: "MTBrannanFragment")
    }
    override func render(from sourceTexture: MTLTexture,
                       to outputTexture: MTLTexture,
                       commandBuffer: MTLCommandBuffer) {
        guard let blowout = samplerTexture(named: "brannanBlowout.png") else {
            return
        }
        guard let map = samplerTexture(named: "brannanProcess.png") else {
            return
        }
        guard let contrast = samplerTexture(named: "brannanContrast.png") else {
            return
        }
        guard let lumaMap = samplerTexture(named: "brannanLuma.png") else {
            return
        }
        guard let screenMap = samplerTexture(named: "brannanScreen.png") else {
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
        renderEncoder.setFragmentTexture(blowout, index: 1)
        renderEncoder.setFragmentTexture(map, index: 2)
        renderEncoder.setFragmentTexture(contrast, index: 3)
        renderEncoder.setFragmentTexture(lumaMap, index: 4)
        renderEncoder.setFragmentTexture(screenMap, index: 5)
        var strength: Float = 1.0
        renderEncoder.setFragmentBytes(&strength, length: MemoryLayout<Float>.stride, index: 0)
        // draw
        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        renderEncoder.endEncoding()
    }
}

