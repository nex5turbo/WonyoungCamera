//
//  Contrast.metal
//  WonyoungCamera
//
//  Created by 워뇨옹 on 2023/01/10.
//

#include <metal_stdlib>
#include "Common.h"
using namespace metal;

fragment half4 contrastFragment(SingleInputVertexIO fragmentInput [[stage_in]],
                                texture2d<half> inputTexture [[texture(0)]],
                                constant float &contrast [[buffer(0)]])
{
    constexpr sampler quadSampler;
    half4 color = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate);
    return half4(((color.rgb - half3(0.5)) * contrast + half3(0.5)), color.a);
}
