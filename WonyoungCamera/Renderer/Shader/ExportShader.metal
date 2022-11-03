//
//  ExportShader.metal
//  WonyoungCamera
//
//  Created by 워뇨옹 on 2022/10/31.
//

#include <metal_stdlib>
using namespace metal;

kernel void export12(texture2d<half, access::write> baseTexture [[ texture(0) ]],
                            array<texture2d<half>, 12> textures [[ texture(1) ]],
                            uint2 gid [[ thread_position_in_grid ]]) {
    float width = baseTexture.get_width();
    float height = baseTexture.get_height();
    float circleSize = width * 0.3;
    float totalWidth = circleSize * 3;
    float totalHeight = circleSize * 4;
    float padding_h = (width - totalWidth) / 2;
    float padding_v = (height - totalHeight) / 2;
    constexpr sampler colorSampler;
    for (int j = 0; j < 4; j++) {
        for (int i = 0; i < 3; i++) {
            if (gid.x >= circleSize * i + padding_h && gid.x <= circleSize * (i + 1) + padding_h &&
                gid.y >= circleSize * j + padding_v && gid.y <= circleSize * (j + 1) + padding_v) {
                int index = i * 4 + j;
                float x = (gid.x - padding_h - circleSize * i) / circleSize;
                float y = (gid.y - padding_v - circleSize * j) / circleSize;
                float2 coord = float2(x, y);
                half4 color = textures[index].sample(colorSampler, coord);
                if (color.a == 0) {
                    baseTexture.write(half4(1), gid);
                } else {
                    baseTexture.write(color, gid);
                }
                return;
            }
        }
    }
    baseTexture.write(half4(1), gid);
}

kernel void export20(texture2d<half, access::write> baseTexture [[ texture(0) ]],
                     array<texture2d<half>, 20> textures [[ texture(1) ]],
                     uint2 gid [[ thread_position_in_grid ]]) {
    float width = baseTexture.get_width();
    float height = baseTexture.get_height();
    float circleSize = width * 0.225;
    float totalWidth = circleSize * 4;
    float totalHeight = circleSize * 5;
    float padding_h = (width - totalWidth) / 2;
    float padding_v = (height - totalHeight) / 2;
    constexpr sampler colorSampler;
    for (int j = 0; j < 5; j++) {
        for (int i = 0; i < 4; i++) {
            if (gid.x >= circleSize * i + padding_h && gid.x <= circleSize * (i + 1) + padding_h &&
                gid.y >= circleSize * j + padding_v && gid.y <= circleSize * (j + 1) + padding_v) {
                int index = i * 5 + j;
                float x = (gid.x - padding_h - circleSize * i) / circleSize;
                float y = (gid.y - padding_v - circleSize * j) / circleSize;
                float2 coord = float2(x, y);
                half4 color = textures[index].sample(colorSampler, coord);
                if (color.a == 0) {
                    baseTexture.write(half4(1), gid);
                } else {
                    baseTexture.write(color, gid);
                }
                return;
            }
        }
    }
    baseTexture.write(half4(1), gid);
}

kernel void export30(texture2d<half, access::write> baseTexture [[ texture(0) ]],
                     array<texture2d<half>, 30> textures [[ texture(1) ]],
                     uint2 gid [[ thread_position_in_grid ]]) {
    float width = baseTexture.get_width();
    float height = baseTexture.get_height();
    float circleSize = width * 0.18;
    float totalWidth = circleSize * 5;
    float totalHeight = circleSize * 6;
    float padding_h = (width - totalWidth) / 2;
    float padding_v = (height - totalHeight) / 2;
    constexpr sampler colorSampler;
    for (int j = 0; j < 6; j++) {
        for (int i = 0; i < 5; i++) {
            if (gid.x >= circleSize * i + padding_h && gid.x <= circleSize * (i + 1) + padding_h &&
                gid.y >= circleSize * j + padding_v && gid.y <= circleSize * (j + 1) + padding_v) {
                int index = i * 6 + j;
                float x = (gid.x - padding_h - circleSize * i) / circleSize;
                float y = (gid.y - padding_v - circleSize * j) / circleSize;
                float2 coord = float2(x, y);
                half4 color = textures[index].sample(colorSampler, coord);
                if (color.a == 0) {
                    baseTexture.write(half4(1), gid);
                } else {
                    baseTexture.write(color, gid);
                }
                return;
            }
        }
    }
    baseTexture.write(half4(1), gid);
}
