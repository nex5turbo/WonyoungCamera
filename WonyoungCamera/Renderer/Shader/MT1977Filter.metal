//
//  MT1977Filter.metal
//  MetalFilters
//
//  Created by alexiscn on 2018/6/8.
//

#include <metal_stdlib>
#include "MTIShaderLib.h"
#include "IFShaderLib.h"
#include "Common.h"
using namespace metalpetal;

fragment half4 MT1977Fragment(SingleInputVertexIO vertexIn [[ stage_in ]],
    texture2d<half, access::sample> inputTexture [[ texture(0) ]],
    texture2d<half, access::sample> map [[ texture(1) ]],
    texture2d<half, access::sample> screen [[ texture(2) ]],
    constant float & strength [[ buffer(0)]])
{
    constexpr sampler s(coord::normalized, address::clamp_to_edge, filter::linear);
    half4 texel = inputTexture.sample(s, vertexIn.textureCoordinate);
    half4 inputTexel = texel;
    float2 lookup;

    lookup.y = .5;

    lookup.x = texel.r;
    texel.r = screen.sample(s, lookup).r;
    lookup.x = texel.g;
    texel.g = screen.sample(s, lookup).r;
    lookup.x = texel.b;
    texel.b = screen.sample(s, lookup).r;

    lookup.x = texel.r;
    texel.r = map.sample(s, lookup).r;
    lookup.x = texel.g;
    texel.g = map.sample(s, lookup).g;
    lookup.x = texel.b;
    texel.b = map.sample(s, lookup).b;
    texel.rgb = mix(inputTexel.rgb, texel.rgb, strength);
    return texel;
}
