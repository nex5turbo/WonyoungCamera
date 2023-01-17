//
//  Vibrance.metal
//  WonyoungCamera
//
//  Created by 워뇨옹 on 2023/01/17.
//

#include <metal_stdlib>
#include "Common.h"
using namespace metal;

fragment half4 vibranceFragment(SingleInputVertexIO fragmentInput [[stage_in]],
                                 texture2d<half> inputTexture [[texture(0)]],
                                 constant float& vibrance [[ buffer(0) ]])
{
    constexpr sampler quadSampler;
    half4 color = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate);
    
    half average = (color.r + color.g + color.b) / 3.0;
    half mx = max(color.r, max(color.g, color.b));
    half amt = (mx - average) * (-vibrance * 3.0);
    color.rgb = mix(color.rgb, half3(mx), amt);
    
    return half4(color);
}
