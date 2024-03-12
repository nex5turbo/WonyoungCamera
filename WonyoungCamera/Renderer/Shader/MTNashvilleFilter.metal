//
//  MTNashvilleFilter.metal
//  MetalFilters
//
//  Created by alexiscn on 2018/6/8.
//

#include <metal_stdlib>
#include "MTIShaderLib.h"
#include "IFShaderLib.h"
#include "Common.h"
using namespace metalpetal;

fragment float4 MTNashvilleFragment(SingleInputVertexIO vertexIn [[ stage_in ]], 
    texture2d<float, access::sample> inputTexture [[ texture(0) ]], 
    texture2d<float, access::sample> map [[ texture(1) ]], 
    constant float & strength [[ buffer(0)]], 
    sampler textureSampler [[ sampler(0) ]])
{
    constexpr sampler s(coord::normalized, address::clamp_to_edge, filter::linear);
    float4 texel = inputTexture.sample(s, vertexIn.textureCoordinate);
    float4 inputTexel = texel;
    texel.rgb = float3(map.sample(s, float2(texel.r, .16666)).r,
                     map.sample(s, float2(texel.g, .5)).g,
                     map.sample(s, float2(texel.b, .83333)).b);
    texel.rgb = mix(inputTexel.rgb, texel.rgb, strength);
    return texel;
}
