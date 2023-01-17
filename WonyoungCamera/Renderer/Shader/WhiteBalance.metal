//
//  WhiteBalance.metal
//  WonyoungCamera
//
//  Created by 워뇨옹 on 2023/01/17.
//

#include <metal_stdlib>
#include "Common.h"
using namespace metal;

constant half3 warmFilter = half3(0.93, 0.54, 0.0);

fragment half4 whiteBalanceFragment(SingleInputVertexIO fragmentInput [[stage_in]],
                                   texture2d<half> inputTexture [[texture(0)]],
                                   constant float *temperature [[buffer(0)]],
                                   constant float *tint [[buffer(1)]])
{
    constexpr sampler quadSampler;
    half4 inColor = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate);
    
    const half3x3 RGBtoYIQ = half3x3(half3(0.299, 0.587, 0.114), half3(0.596, -0.274, -0.322), half3(0.212, -0.523, 0.311));
    const half3x3 YIQtoRGB = half3x3(half3(1.0, 0.956, 0.621), half3(1.0, -0.272, -0.647), half3(1.0, -1.105, 1.702));
    
    half3 yiq = RGBtoYIQ * inColor.rgb;
    yiq.b = clamp(yiq.b + half(*tint) * 0.5226 * 0.1, -0.5226, 0.5226);
    const half3 rgb = YIQtoRGB * yiq;
    
    const half3 processed = half3((rgb.r < 0.5 ? (2.0 * rgb.r * warmFilter.r) : (1.0 - 2.0 * (1.0 - rgb.r) * (1.0 - warmFilter.r))),
                                  (rgb.g < 0.5 ? (2.0 * rgb.g * warmFilter.g) : (1.0 - 2.0 * (1.0 - rgb.g) * (1.0 - warmFilter.g))),
                                  (rgb.b < 0.5 ? (2.0 * rgb.b * warmFilter.b) : (1.0 - 2.0 * (1.0 - rgb.b) * (1.0 - warmFilter.b))));
    
    return half4(mix(rgb, processed, half(*temperature)), inColor.a);
    
}
