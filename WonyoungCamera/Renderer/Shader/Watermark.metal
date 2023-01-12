//
//  Watermark.metal
//  WonyoungCamera
//
//  Created by 워뇨옹 on 2023/01/12.
//

#include <metal_stdlib>
#include "Common.h"
using namespace metal;

fragment half4 watermarkFragment(SingleInputVertexIO fragmentInput [[stage_in]],
                                texture2d<half> inputTexture [[texture(0)]],
                                 texture2d<half> watermarkTexture [[texture(1)]])
{
    constexpr sampler quadSampler(min_filter::bicubic, mag_filter::bicubic);
    float2 inputSize = float2(inputTexture.get_width(), inputTexture.get_height());
    float2 watermarkSize = float2(watermarkTexture.get_width(), watermarkTexture.get_height());
    float inputRatio = inputSize.x / inputSize.y;
    float watermarkRatio = watermarkSize.x / watermarkSize.y;
    float waterX = 0.3;
    float waterY = waterX / watermarkRatio;

    if ((fragmentInput.textureCoordinate.x >= 0.65 && fragmentInput.textureCoordinate.y / inputRatio >= 0.97 / inputRatio - waterY) &&
        (fragmentInput.textureCoordinate.x <= 0.95 && fragmentInput.textureCoordinate.y / inputRatio <= 0.97 / inputRatio)) {

        float2 waterCoord = float2((fragmentInput.textureCoordinate.x - 0.65) / waterX,
                                   (fragmentInput.textureCoordinate.y / inputRatio - (0.97 / inputRatio - waterY)) / waterY);
        half4 waterColor = watermarkTexture.sample(quadSampler, waterCoord);
        if (waterColor.a != 0) {
            return waterColor;
        }
    }
    half4 color = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate);
    return color;
}
