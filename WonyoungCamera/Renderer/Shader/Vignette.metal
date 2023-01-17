//
//  Vignette.metal
//  WonyoungCamera
//
//  Created by 워뇨옹 on 2023/01/17.
//

#include <metal_stdlib>
#include "Common.h"
using namespace metal;

typedef struct {
    float2 vignetteCenter;
    float3 vignetteColor;
    float vignetteStart;
    float vignetteEnd;
    float vignettePercent;
} VignetteUniform;

fragment half4 vignetteFragment(SingleInputVertexIO fragmentInput [[stage_in]],
                                       texture2d<half> inputTexture [[texture(0)]],
                                       constant VignetteUniform& uniform [[buffer(1)]])
{
    constexpr sampler quadSampler;
    half4 color = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate);
    
    float d = distance(fragmentInput.textureCoordinate, uniform.vignetteCenter);
    float percent = smoothstep(uniform.vignetteStart, uniform.vignetteEnd, d) * uniform.vignettePercent;
    return half4(mix(color.rgb, half3(uniform.vignetteColor.rgb), half(percent)), color.a);
}
