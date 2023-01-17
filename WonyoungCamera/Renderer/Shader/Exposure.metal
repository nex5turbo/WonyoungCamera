//
//  Exposure.metal
//  WonyoungCamera
//
//  Created by 워뇨옹 on 2023/01/17.
//

#include <metal_stdlib>
#include "Common.h"
using namespace metal;

fragment half4 exposureFragment(SingleInputVertexIO fragmentInput [[stage_in]],
                                  texture2d<half> inputTexture [[texture(0)]],
                                  constant float& exposure [[ buffer(0) ]])
{
    constexpr sampler quadSampler;
    half4 color = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate);
    
    return half4((color.rgb * pow(2.0, exposure)), color.a);
}
