//
//  Saturation.metal
//  WonyoungCamera
//
//  Created by 워뇨옹 on 2023/01/17.
//

#include <metal_stdlib>
#include "Common.h"
using namespace metal;

fragment half4 saturationFragment(SingleInputVertexIO fragmentInput [[stage_in]],
                                  texture2d<half> inputTexture [[texture(0)]],
                                  constant float &saturation [[buffer(0)]])
{
    constexpr sampler quadSampler;
    half4 color = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate);
//    half3 hsv = rgb2hsv(color.rgb);
//    hsv.y = hsv.y * saturation;
//    half3 rgb = hsv2rgb(hsv);
//    half4 outputColor = half4(rgb, 1);
//    return outputColor;
//    from RSSaturation
    half luminance = dot(color.rgb, luminanceWeighting);
    return half4(mix(half3(luminance), color.rgb, half(saturation)), color.a);
}
