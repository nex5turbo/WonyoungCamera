//
//  Grain.metal
//  WonyoungCamera
//
//  Created by 워뇨옹 on 2023/01/17.
//

#include <metal_stdlib>
#include "Common.h"
using namespace metal;

fragment half4 grainFragment(SingleInputVertexIO fragmentInput [[stage_in]],
                                       texture2d<half> inputTexture [[texture(0)]],
                                       constant float &grainStrength [[buffer(1)]])
{
    constexpr sampler quadSampler;
    half4 color = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate);
    
    float strength = 100.0 * grainStrength;
    
    float x = (fragmentInput.textureCoordinate.x + 4.0 ) * (fragmentInput.textureCoordinate.y + 4.0 ) * 10;
    half4 grain = half4(fmod((fmod(x, 13.0) + 1.0) * (fmod(x, 123.0) + 1.0), 0.01)-0.005) * strength;
    half4 fragColor = color + grain;
    return fragColor;
}
