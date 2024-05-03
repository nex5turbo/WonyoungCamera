//
//  MT1977Pipeline.swift
//  Imica
//
//  Created by 워뇨옹 on 2023/07/24.
//

import Foundation
import MetalKit

class IdolPipeline: FilterPipeline {
    override var name: String { return "Idol" }
    override var sampleImageName: String { return .samplePinkBaby }
    override func makeRenderPipelineState() -> MTLRenderPipelineState? {
        return makeRenderPipelineState(vertexFunctionName: "oneInputVertex", fragmentFunctionName: "MTAdenFragment")
    }
    override func render(from sourceTexture: MTLTexture,
                       to outputTexture: MTLTexture,
                       commandBuffer: MTLCommandBuffer) {
        guard let lookup = samplerTexture(named: "aden_map.png") else {
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
        renderEncoder.setFragmentTexture(lookup, index: 1)
        var strength: Float = 1.0
        renderEncoder.setFragmentBytes(&strength, length: MemoryLayout<Float>.stride, index: 0)
        // draw
        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        renderEncoder.endEncoding()
    }
}
