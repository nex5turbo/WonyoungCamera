//
//  WhiteBalancePipeline.swift
//  WonyoungCamera
//
//  Created by 워뇨옹 on 2023/01/17.
//

import MetalKit

struct WhiteBalanceProperties {
    let tint: Float
    let temperature: Float
}

class WhiteBalancePipeline: FilterPipeline {
    override func makeRenderPipelineState() -> MTLRenderPipelineState? {
        return makeRenderPipelineState(vertexFunctionName: "oneInputVertex",
                                       fragmentFunctionName: "whiteBalanceFragment")
    }
    // github.com/Silence-GitHub/BBMetalImage/blob/master/BBMetalImage/BBMetalImage/BBMetalWhiteBalanceFilter.swift
    // make range 3000 ~ 7000 and apply conversion from BBMetalImage
    // 5000 is original image
    private func convertTemperature(_ temperature: Float) -> Float {
        let temp = temperature * 4000 + 3000
        return temperature < 5000 ? 0.0004 * (temp - 5000) : 0.00006 * (temp - 5000)
    }

    // use range 0~1 and create new conversion
    // 0.5 is original image
    private func convertTemperature2(_ temperature: Float) -> Float {
        return (temperature - 0.5) * 0.5
    }
    private func convertTint(_ tint: Float) -> Float {
        return tint - 0.5
    }

    public func render(whiteBalanceProperties: WhiteBalanceProperties, from sourceTexture: MTLTexture,
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
        let newTemperature: Float = convertTemperature2(whiteBalanceProperties.temperature)
        let convertedTint = convertTint(whiteBalanceProperties.tint)
        renderEncoder.setFragmentTexture(sourceTexture, index: 0)
        if whiteBalanceBuffer1 == nil {
            whiteBalanceBuffer1 = makeBuffer(float: newTemperature)
        } else {
            var valueBuffer = newTemperature
            memcpy(whiteBalanceBuffer1?.contents(), &valueBuffer, MemoryLayout<Float>.size)
        }
        renderEncoder.setFragmentBuffer(whiteBalanceBuffer1, offset: 0, index: 0)
        if whiteBalanceBuffer2 == nil {
            whiteBalanceBuffer2 = makeBuffer(float: convertedTint)
        } else {
            var valueBuffer = convertedTint
            memcpy(whiteBalanceBuffer2?.contents(), &valueBuffer, MemoryLayout<Float>.size)
        }
        renderEncoder.setFragmentBuffer(whiteBalanceBuffer2, offset: 0, index: 1)
        // draw
        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        renderEncoder.endEncoding()
    }
}
