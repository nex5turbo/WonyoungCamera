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
    constexpr sampler quadSampler(min_filter::linear, mag_filter::linear);
    float2 inputSize = float2(inputTexture.get_width(), inputTexture.get_height());
    float2 watermarkSize = float2(watermarkTexture.get_width(), watermarkTexture.get_height());
    float inputRatio = inputSize.x / inputSize.y;
    float watermarkRatio = watermarkSize.x / watermarkSize.y;
    float waterX = 0.2;
    float waterY = waterX / watermarkRatio;
    half4 color = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate);

    if ((fragmentInput.textureCoordinate.x >= 0.8 && fragmentInput.textureCoordinate.y / inputRatio >= 0.97 / inputRatio - waterY) &&
        (fragmentInput.textureCoordinate.x <= 1 && fragmentInput.textureCoordinate.y / inputRatio <= 0.97 / inputRatio)) {

        float2 waterCoord = float2((fragmentInput.textureCoordinate.x - 0.8) / waterX,
                                   (fragmentInput.textureCoordinate.y / inputRatio - (0.97 / inputRatio - waterY)) / waterY);
        half4 waterColor = watermarkTexture.sample(quadSampler, waterCoord);
        color = mix(color, waterColor, waterColor.a);
    }
    
    return color;
}
