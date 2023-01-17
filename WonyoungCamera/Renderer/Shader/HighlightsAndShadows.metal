//
//  HighlightsAndShadows.metal
//  WonyoungCamera
//
//  Created by 워뇨옹 on 2023/01/17.
//

#include <metal_stdlib>
#include "Common.h"
using namespace metal;

fragment half4 highlightShadowFragment(SingleInputVertexIO fragmentInput [[stage_in]],
                                texture2d<half> inputTexture [[texture(0)]],
                                constant float *highlights [[buffer(0)]],
                                       constant float *shadows [[buffer(1)]])
{
    constexpr sampler quadSampler;
    half4 color = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate);
    half luminance = dot(color.rgb, luminanceWeighting);
    half shadow = clamp((pow(luminance, 1.0h/(half(*shadows)+1.0h)) + (-0.76)*pow(luminance, 2.0h/(half(*shadows)+1.0h))) - luminance, 0.0, 1.0);
    half highlight = clamp((1.0 - (pow(1.0-luminance, 1.0/(2.0-half(*highlights))) + (-0.8)*pow(1.0-luminance, 2.0/(2.0-half(*highlights))))) - luminance, -1.0, 0.0);
    half3 result = half3(0.0, 0.0, 0.0) + ((luminance + shadow + highlight) - 0.0) * ((color.rgb - half3(0.0, 0.0, 0.0))/(luminance - 0.0));
    
    return half4(result.rgb, color.a);
}
