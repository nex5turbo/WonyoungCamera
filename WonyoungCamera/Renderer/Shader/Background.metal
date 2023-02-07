//
//  Background.metal
//  WonyoungCamera
//
//  Created by 워뇨옹 on 2023/02/06.
//

#include <metal_stdlib>
#include "Common.h"
using namespace metal;

fragment half4 backgroundFragment(SingleInputVertexIO fragmentInput [[stage_in]],
                                       texture2d<half> inputTexture [[texture(0)]])
{
    constexpr sampler quadSampler;
    half4 color = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate);
    
    return color;
}
