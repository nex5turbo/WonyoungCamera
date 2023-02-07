//
//  KernelShader.metal
//  YoungsCamera
//
//  Created by 워뇨옹 on 2022/08/24.
//

#include <metal_stdlib>
using namespace metal;

half4 applyFilter(half4 textureColor, texture2d<half> filterTexture);
half4 applyBrightness(half4 color, float brightness);
half4 applyContrast(half4 inputColor, half contrast);
half4 applySaturation( half4 inputColor, half saturation);

kernel void roundingImage(texture2d<half, access::write> writeTexture [[ texture(0) ]],
                          texture2d<half> readTexture [[ texture(1) ]],
                          texture2d<half> circleTexture [[ texture(2) ]],

                          constant float &scale [[ buffer(0) ]],
                          constant float &borderWidth [[ buffer(1) ]],
                          constant float4 &borderColor [[ buffer(2) ]],
                          constant bool &hasBackground [[ buffer(3) ]],
                          uint2 gid [[ thread_position_in_grid ]]) {
    float textureWidth = readTexture.get_width();
    float textureHeight = readTexture.get_height();
    float outputHeight = writeTexture.get_height();
    
    float halfWidth = textureWidth / 2;
    float halfHeight = textureHeight / 2;

    constexpr sampler colorSampler;
    float2 coord = float2(gid);
    // 절반 사이즈를 빼서 scale 적용한 다음 다시 절반 사이즈 더해주면 된다.
    coord.x -= halfWidth;
    coord.y -= halfHeight;
    coord.x *= scale;
    coord.y *= scale;
    coord.x += halfWidth;
    coord.y += halfHeight;
    coord.x = (coord.x) / textureWidth;
    coord.y = (coord.y + ((textureHeight - outputHeight) / 3)) / textureHeight;
    
    half4 color = readTexture.sample(colorSampler, coord);
    float outterSize = halfWidth - (100 * (textureWidth / 2160));
    float innerSize = halfWidth - ((100 + ((halfWidth - 100) / 10) * borderWidth) * (textureWidth / 2160));
    float currentDistance = distance(float2(gid), float2(halfWidth, halfWidth));
    if (currentDistance > outterSize) {
        if (hasBackground) {
            return;
        } else {
            writeTexture.write(half4(0), gid);
            return;
        }
    }
    
    if (currentDistance > innerSize) {
        writeTexture.write(half4(borderColor), gid);
        return;
    }
    
    writeTexture.write(color, gid);
}

half4 applyFilter(half4 textureColor, texture2d<half> filterTexture) {
    half4 base = textureColor;

    half blueColor = base.b * 63.0h;

    half2 quad1;
    quad1.y = floor(floor(blueColor) / 8.0h);
    quad1.x = floor(blueColor) - (quad1.y * 8.0h);

    half2 quad2;
    quad2.y = floor(ceil(blueColor) / 8.0h);
    quad2.x = ceil(blueColor) - (quad2.y * 8.0h);

    float2 texPos1;
    texPos1.x = (quad1.x * 0.125) + 0.5/512.0 + ((0.125 - 1.0/512.0) * base.r);
    texPos1.y = (quad1.y * 0.125) + 0.5/512.0 + ((0.125 - 1.0/512.0) * base.g);

    float2 texPos2;
    texPos2.x = (quad2.x * 0.125) + 0.5/512.0 + ((0.125 - 1.0/512.0) * base.r);
    texPos2.y = (quad2.y * 0.125) + 0.5/512.0 + ((0.125 - 1.0/512.0) * base.g);

    constexpr sampler quadSampler3;
    half4 newColor1 = filterTexture.sample(quadSampler3, texPos1);
    constexpr sampler quadSampler4;
    half4 newColor2 = filterTexture.sample(quadSampler4, texPos2);

    half4 newColor = mix(newColor1, newColor2, fract(blueColor));
    return half4(mix(base, half4(newColor.rgb, base.w), half(1)));
}

kernel void applyColorFilter(texture2d<half, access::write> writeTexture [[ texture(0) ]],
                             texture2d<half> readTexture [[ texture(1) ]],
                             texture2d<half> lutTexture [[ texture(2) ]],
                             uint2 gid [[ thread_position_in_grid ]]) {
    half4 color = readTexture.read(gid);
    half4 filteredColor = applyFilter(color, lutTexture);
    writeTexture.write(filteredColor, gid);
}
