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
                          texture2d<half> lutTexture [[ texture(2) ]],
                          texture2d<half> circleTexture [[ texture(3) ]],

                          constant bool &shouldFlip [[ buffer(0) ]],
                          constant float &textureWidth [[ buffer(1) ]],
                          constant float &textureHeight [[ buffer(2) ]],
                          constant bool &shouldFilter [[ buffer(3) ]],
                          constant float &scale [[ buffer(4) ]],
                          constant float &brightness [[ buffer(5) ]],
                          constant float &contrast [[ buffer(6) ]],
                          constant float &saturation [[ buffer(7) ]],
                          uint2 gid [[ thread_position_in_grid ]]) {
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
    coord.y = (coord.y + (200 * scale)) / textureHeight;
    if (shouldFlip) {
        coord.x = 1 - coord.x;
    }
    half4 color = readTexture.sample(colorSampler, coord);
    if (distance(float2(gid), float2(halfWidth, halfWidth)) > halfWidth - (100 * (textureWidth / 2160))) {
        writeTexture.write(half4(0), gid);
        return;
    }
    if (distance(float2(gid), float2(halfWidth, halfWidth)) > halfWidth - (120 * (textureWidth / 2160))) {
        writeTexture.write(half4(0, 0, 0, 1), gid);
        return;
    }

    if (shouldFilter) {
        half4 filteredColor = applyFilter(color, lutTexture);
        filteredColor = applyBrightness(filteredColor, brightness);
        filteredColor = applyContrast(filteredColor, contrast);
        filteredColor = applySaturation(filteredColor, saturation);
        writeTexture.write(filteredColor, gid);
        return;
    } else {
        color = applyBrightness(color, brightness);
        color = applyContrast(color, contrast);
        color = applySaturation(color, saturation);
        writeTexture.write(color, gid);
    }
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

//half4 applyBrightness(half4 color, float brightness) {
//    return half4(color.rgb + brightness, color.a);
//}

half3 rgb2hsv(half3 rgb) {
    half3 hsv;
    half4 K = half4(0.0, -1.0/3.0, 2.0/3.0, -1.0);
    half4 p = mix(half4(rgb.bg, K.wz), half4(rgb.gb, K.xy), step(rgb.b, rgb.g));
    half4 q = mix(half4(p.xyw, rgb.r), half4(rgb.r, p.yzx), step(p.x, rgb.r));
    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    hsv.x = abs(q.z + (q.w - q.y) / (6.0 * d + e));
    hsv.y = d / (q.x + e);
    hsv.z = q.x;
    return hsv;
}
half3 hsv2rgb(half3 hsv) {
    half3 rgb;
    half4 K = half4(1.0, 2.0/3.0, 1.0/3.0, 3.0);
    half3 p = abs(fract(hsv.xxx + K.xyz) * 6.0 - K.www);
    rgb = hsv.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), hsv.y);
    return rgb;
}

half4 applyBrightness(half4 color, float brightness) {
    half3 hsv = rgb2hsv(color.rgb);
    hsv.z *= brightness;
    return half4(hsv2rgb(hsv), color.a);
}

half4 applyContrast(half4 inputColor, half contrast) {
    half4 outputColor;
    outputColor.rgb = (inputColor.rgb - 0.5) * contrast + 0.5;
    outputColor.a = inputColor.a;
    return outputColor;
}

half4 applySaturation(half4 inputColor, half saturation) {
    half3 hsv = rgb2hsv(inputColor.rgb);
    hsv.y = hsv.y * saturation;
    half3 rgb = hsv2rgb(hsv);
    half4 outputColor = half4(rgb, 1);
    return outputColor;
    
}

kernel void sampleImage(texture2d<half, access::write> writeTexture [[ texture(0) ]],
                        texture2d<half> readTexture [[ texture(1) ]],
                        texture2d<half> lutTexture [[ texture(2) ]],
                        uint2 gid [[ thread_position_in_grid ]]) {
    half4 color = readTexture.read(gid);
    half4 filteredColor = applyFilter(color, lutTexture);
    writeTexture.write(filteredColor, gid);
}
