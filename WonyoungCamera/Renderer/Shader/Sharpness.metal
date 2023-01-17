//
//  Sharpness.metal
//  WonyoungCamera
//
//  Created by 워뇨옹 on 2023/01/17.
//

#include <metal_stdlib>
#include "Common.h"
using namespace metal;

fragment half4 sharpenFragment(SingleInputVertexIO fragmentInput [[stage_in]],
                              texture2d<half> inputTexture [[texture(0)]],
                              constant float& sharpness [[buffer(0)]])
{
    const float x = float(fragmentInput.textureCoordinate.x);
    const float y = float(fragmentInput.textureCoordinate.y);
    const float width = float(inputTexture.get_width());
    const float height = float(inputTexture.get_height());
    
    const float2 leftCoordinate = float2((x - 1) / width, y / height);
    const float2 rightCoordinate = float2((x + 1) / width, y / height);
    const float2 topCoordinate = float2(x / width, (y - 1) / height);
    const float2 bottomCoordinate = float2(x / width, (y + 1) / height);
    
    
    constexpr sampler quadSampler(mag_filter::linear, min_filter::linear);
    const half4 inColor = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate);
    const half4 leftColor = inputTexture.sample(quadSampler, leftCoordinate);
    const half4 rightColor = inputTexture.sample(quadSampler, rightCoordinate);
    const half4 topColor = inputTexture.sample(quadSampler, topCoordinate);
    const half4 bottomColor = inputTexture.sample(quadSampler, bottomCoordinate);
    
    const half centerMultiplier = 1.0 + 4.0 * half(sharpness);
    const half edgeMultiplier = half(sharpness);
    const half4 outColor((inColor.rgb * centerMultiplier - (leftColor.rgb + rightColor.rgb + topColor.rgb + bottomColor.rgb) * edgeMultiplier), bottomColor.a);
    
    return outColor;
}
