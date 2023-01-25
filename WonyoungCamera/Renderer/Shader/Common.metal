//
//  Common.metal
//  WonyoungCamera
//
//  Created by 워뇨옹 on 2023/01/10.
//

#include <metal_stdlib>
#include "Common.h"
using namespace metal;

half4 blendAddOn(half4 x, half4 y) { // x on y
    half xa = x.a;
    if (xa < 1.0h) {
        half xb = 1.0h - xa;
        half ya = y.a;
        return half4(x.r*xa + y.r*ya*xb,
                     x.g*xa + y.g*ya*xb,
                     x.b*xa + y.b*ya*xb,
                     xa + ya*xb);
    }
    return x;
}

half4 blendMix(half4 overlay, half4 base) {
    return mix(base, overlay, overlay.a);
}

half4 blendSourceOver(half4 overlay, half4 base) {
    return mix(overlay, base, overlay.a);
}

half4 blendAdd(half4 overlay, half4 base) {
    half r;
    if (overlay.r * base.a + base.r * overlay.a >= overlay.a * base.a) {
        r = overlay.a * base.a + overlay.r * (1.0h - base.a) + base.r * (1.0h - overlay.a);
    } else {
        r = overlay.r + base.r;
    }
    
    half g;
    if (overlay.g * base.a + base.g * overlay.a >= overlay.a * base.a) {
        g = overlay.a * base.a + overlay.g * (1.0h - base.a) + base.g * (1.0h - overlay.a);
    } else {
        g = overlay.g + base.g;
    }
    
    half b;
    if (overlay.b * base.a + base.b * overlay.a >= overlay.a * base.a) {
        b = overlay.a * base.a + overlay.b * (1.0h- base.a) + base.b * (1.0h - overlay.a);
    } else {
        b = overlay.b + base.b;
    }
    
    half a = overlay.a + base.a - overlay.a * base.a;
    
    return half4(r, g, b, a);
}

half4 blendNormal(half4 color1, half4 color2) {
    half4 outputColor;
    
    half a = color1.a + color2.a * (1.0h - color1.a);
    half alphaDivisor = a + step(a, 0.0h); // Protect against a divide-by-zero blacking out things in the output
    
    outputColor.r = (color1.r * color1.a + color2.r * color2.a * (1.0h - color1.a))/alphaDivisor;
    outputColor.g = (color1.g * color1.a + color2.g * color2.a * (1.0h - color1.a))/alphaDivisor;
    outputColor.b = (color1.b * color1.a + color2.b * color2.a * (1.0h - color1.a))/alphaDivisor;
    outputColor.a = a;
    
    return outputColor;
}



vertex SingleInputVertexIO noInputVertex(const device packed_float2 *position [[buffer(0)]],
                                         unsigned int vid [[vertex_id]])
{
    SingleInputVertexIO outputVertices;
    
    outputVertices.position = float4(position[vid], 0, 1.0);
    outputVertices.textureCoordinate = float2(0.0);
    
    return outputVertices;
}

vertex SingleInputVertexIO oneInputVertex(const device packed_float2 *position [[buffer(0)]],
                                          const device packed_float2 *texturecoord [[buffer(1)]],
                                          unsigned int vid [[vertex_id]])
{
    SingleInputVertexIO outputVertices;
    
    outputVertices.position = float4(position[vid], 0, 1.0);
    outputVertices.textureCoordinate = texturecoord[vid];
    
    return outputVertices;
}

fragment half4 passthroughFragment(SingleInputVertexIO fragmentInput [[stage_in]],
                                   texture2d<half> inputTexture [[texture(0)]])
{
    if (fragmentInput.position[0] < 50) {
        return half4(1.0, 0.0, 0.0, 1.0);
    }
    if (fragmentInput.position[1] > 300) {
        return half4(0.0, 1.0, 0.0, 1.0);
    }
    return half4(0.0, 1.0, 1.0, 1.0);
//    constexpr sampler quadSampler;
//    half4 color = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate);
//
//    return color;
}

vertex TwoInputVertexIO twoInputVertex(const device packed_float2 *position [[buffer(0)]],
                                       const device packed_float2 *texturecoord [[buffer(1)]],
                                       const device packed_float2 *texturecoord2 [[buffer(2)]],
                                       uint vid [[vertex_id]])
{
    TwoInputVertexIO outputVertices;
    
    outputVertices.position = float4(position[vid], 0, 1.0);
    outputVertices.textureCoordinate = texturecoord[vid];
    outputVertices.textureCoordinate2 = texturecoord2[vid];

    return outputVertices;
}

fragment half4 normalBlendFragment(TwoInputVertexIO fragmentInput [[stage_in]],
                                  texture2d<half> inputTexture [[texture(0)]],
                                  texture2d<half> inputTexture2 [[texture(1)]])
{
    constexpr sampler quadSampler;
    half4 textureColor = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate);
    constexpr sampler quadSampler2;
    half4 textureColor2 = inputTexture2.sample(quadSampler2, fragmentInput.textureCoordinate2);
    
    half4 outputColor;
    
    half a = textureColor.a + textureColor2.a * (1.0h - textureColor.a);
    half alphaDivisor = a + step(a, 0.0h); // Protect against a divide-by-zero blacking out things in the output
    
    outputColor.r = (textureColor.r * textureColor.a + textureColor2.r * textureColor2.a * (1.0h - textureColor.a))/alphaDivisor;
    outputColor.g = (textureColor.g * textureColor.a + textureColor2.g * textureColor2.a * (1.0h - textureColor.a))/alphaDivisor;
    outputColor.b = (textureColor.b * textureColor.a + textureColor2.b * textureColor2.a * (1.0h - textureColor.a))/alphaDivisor;
    outputColor.a = a;
    
    return outputColor;
}

struct VertexIn {
    packed_float3 position;
    packed_float4 color;
};

struct VertexOut {
    float4 computedPosition [[position]];
    float4 color;
};

vertex VertexOut basic_vertex(const device VertexIn* vertex_array [[ buffer(0) ]],
                              unsigned int vid [[ vertex_id ]])
{
    VertexIn v = vertex_array[vid];
    VertexOut outVertex = VertexOut();
    outVertex.computedPosition = float4(v.position, 1.0);
    outVertex.color = v.color;
    return outVertex;
}

fragment float4 basic_fragment(VertexOut interpolated [[stage_in]])
{
    return float4(1.0, 0.0, 1.0, 1.0);
//  return float4(interpolated.color);
}

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
