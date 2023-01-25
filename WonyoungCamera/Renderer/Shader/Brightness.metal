//
//  Brightness.metal
//  WonyoungCamera
//
//  Created by 워뇨옹 on 2023/01/17.
//

#include <metal_stdlib>
#include "Common.h"
using namespace metal;

fragment half4 brightnessFragment(SingleInputVertexIO fragmentInput [[stage_in]],
                                  texture2d<half> inputTexture [[texture(0)]],
                                  constant float &brightness [[buffer(0)]])
{
    constexpr sampler quadSampler;
    half4 color = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate);
    half3 hsv = rgb2hsv(color.rgb);
    hsv.z *= brightness;
    return half4(hsv2rgb(hsv), color.a);
//    from RSBrightness
//    return half4(color.rgb + brightness, color.a);
}
