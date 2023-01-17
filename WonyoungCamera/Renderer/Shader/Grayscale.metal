//
//  Grayscale.metal
//  WonyoungCamera
//
//  Created by 워뇨옹 on 2023/01/17.
//

#include <metal_stdlib>
#include "Common.h"
using namespace metal;

// Rec 709 LUMA values for grayscale image conversion
constant half3 kRec709Luma = half3(0.2126, 0.7152, 0.0722);

fragment half4 grayscaleFragment(SingleInputVertexIO fragmentInput [[stage_in]],
                                   texture2d<half> inputTexture [[texture(0)]])
{
    constexpr sampler quadSampler;
    half4 color = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate);
    half gray = dot(color.rgb, kRec709Luma);
    return half4(gray, gray, gray, color.a);
}
