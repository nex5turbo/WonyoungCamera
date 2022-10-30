//
//  ExportShader.metal
//  WonyoungCamera
//
//  Created by 워뇨옹 on 2022/10/31.
//

#include <metal_stdlib>
using namespace metal;

//kernel void export12(texture2d<half, access::write> baseTexture [[ texture(0) ]],
//                     array<texture2d<half>, 12> textures [[ texture(1) ]],
//                     uint2 gid [[ thread_position_in_grid ]]) {
//    float x = gid.x / baseTexture.get_width();
//    float y = gid.y / baseTexture.get_height();
//    constexpr sampler colorSampler;
//    half4 color = textures[0].sample(colorSampler, float2(x, y));
//    baseTexture.write(color, gid);
//}
//
//kernel void export24(texture2d<half, access::write> baseTexture [[ texture(0) ]],
//                     array<texture2d<half>, 24> textures [[ texture(1) ]],
//                     uint2 gid [[ thread_position_in_grid ]]) {
//
//}
//
//kernel void export40(texture2d<half, access::write> baseTexture [[ texture(0) ]],
//                     array<texture2d<half>, 40> textures [[ texture(1) ]],
//                     uint2 gid [[ thread_position_in_grid ]]) {
//
//}

// 안될 때 최후의 수단
kernel void export12
(
    texture2d<half, access::write> baseTexture [[ texture(0) ]],
    texture2d<half> texture1 [[ texture(1) ]],
    texture2d<half> texture2 [[ texture(2) ]],
    texture2d<half> texture3 [[ texture(3) ]],
    texture2d<half> texture4 [[ texture(4) ]],
    texture2d<half> texture5 [[ texture(5) ]],
    texture2d<half> texture6 [[ texture(6) ]],
    texture2d<half> texture7 [[ texture(7) ]],
    texture2d<half> texture8 [[ texture(8) ]],
    texture2d<half> texture9 [[ texture(9) ]],
    texture2d<half> texture10 [[ texture(10) ]],
    texture2d<half> texture11 [[ texture(11) ]],
    texture2d<half> texture12 [[ texture(12) ]],
    uint2 gid [[ thread_position_in_grid ]]
) {
    float x = gid.x / float(baseTexture.get_width());
    float y = gid.y / float(baseTexture.get_height());
    constexpr sampler colorSampler;
    half4 color = texture1.sample(colorSampler, float2(x, y));
    baseTexture.write(color, gid);
}

kernel void export24
(
    texture2d<half> baseTexture [[ texture(0) ]],
    texture2d<half> texture1 [[ texture(1) ]],
    texture2d<half> texture2 [[ texture(2) ]],
    texture2d<half> texture3 [[ texture(3) ]],
    texture2d<half> texture4 [[ texture(4) ]],
    texture2d<half> texture5 [[ texture(5) ]],
    texture2d<half> texture6 [[ texture(6) ]],
    texture2d<half> texture7 [[ texture(7) ]],
    texture2d<half> texture8 [[ texture(8) ]],
    texture2d<half> texture9 [[ texture(9) ]],
    texture2d<half> texture10 [[ texture(10) ]],
    texture2d<half> texture11 [[ texture(11) ]],
    texture2d<half> texture12 [[ texture(12) ]],
    texture2d<half> texture13 [[ texture(13) ]],
    texture2d<half> texture14 [[ texture(14) ]],
    texture2d<half> texture15 [[ texture(15) ]],
    texture2d<half> texture16 [[ texture(16) ]],
    texture2d<half> texture17 [[ texture(17) ]],
    texture2d<half> texture18 [[ texture(18) ]],
    texture2d<half> texture19 [[ texture(19) ]],
    texture2d<half> texture20 [[ texture(20) ]],
    texture2d<half> texture21 [[ texture(21) ]],
    texture2d<half> texture22 [[ texture(22) ]],
    texture2d<half> texture23 [[ texture(23) ]],
    texture2d<half> texture24 [[ texture(24) ]],
    uint2 gid [[ thread_position_in_grid ]]
) {
}

kernel void export40
(
    texture2d<half> baseTexture [[ texture(0) ]],
    texture2d<half> texture1 [[ texture(1) ]],
    texture2d<half> texture2 [[ texture(2) ]],
    texture2d<half> texture3 [[ texture(3) ]],
    texture2d<half> texture4 [[ texture(4) ]],
    texture2d<half> texture5 [[ texture(5) ]],
    texture2d<half> texture6 [[ texture(6) ]],
    texture2d<half> texture7 [[ texture(7) ]],
    texture2d<half> texture8 [[ texture(8) ]],
    texture2d<half> texture9 [[ texture(9) ]],
    texture2d<half> texture10 [[ texture(10) ]],
    texture2d<half> texture11 [[ texture(11) ]],
    texture2d<half> texture12 [[ texture(12) ]],
    texture2d<half> texture13 [[ texture(13) ]],
    texture2d<half> texture14 [[ texture(14) ]],
    texture2d<half> texture15 [[ texture(15) ]],
    texture2d<half> texture16 [[ texture(16) ]],
    texture2d<half> texture17 [[ texture(17) ]],
    texture2d<half> texture18 [[ texture(18) ]],
    texture2d<half> texture19 [[ texture(19) ]],
    texture2d<half> texture20 [[ texture(20) ]],
    texture2d<half> texture21 [[ texture(21) ]],
    texture2d<half> texture22 [[ texture(22) ]],
    texture2d<half> texture23 [[ texture(23) ]],
    texture2d<half> texture24 [[ texture(24) ]],
    texture2d<half> texture25 [[ texture(25) ]],
    texture2d<half> texture26 [[ texture(26) ]],
    texture2d<half> texture27 [[ texture(27) ]],
    texture2d<half> texture28 [[ texture(28) ]],
    texture2d<half> texture29 [[ texture(29) ]],
    texture2d<half> texture30 [[ texture(30) ]],
    texture2d<half> texture31 [[ texture(31) ]],
    texture2d<half> texture32 [[ texture(32) ]],
    texture2d<half> texture33 [[ texture(33) ]],
    texture2d<half> texture34 [[ texture(34) ]],
    texture2d<half> texture35 [[ texture(35) ]],
    texture2d<half> texture36 [[ texture(36) ]],
    texture2d<half> texture37 [[ texture(37) ]],
    texture2d<half> texture38 [[ texture(38) ]],
    texture2d<half> texture39 [[ texture(39) ]],
    texture2d<half> texture40 [[ texture(40) ]],
    uint2 gid [[ thread_position_in_grid ]]
) {
}

