//
//  Common.h
//  WonyoungCamera
//
//  Created by 워뇨옹 on 2023/01/10.
//

#ifndef Common_h
#define Common_h

half4 blendAddOn(half4 x, half4 y); // add x on y

half4 blendMix(half4 overlay, half4 base);
half4 blendSourceOver(half4 overlay, half4 base);
half4 blendAdd(half4 overlay, half4 base);
half4 blendNormal(half4 color1, half4 color2);
half3 rgb2hsv(half3 rgb);
half3 hsv2rgb(half3 hsv);

// Luminance Constants
constant half3 luminanceWeighting = half3(0.2125, 0.7154, 0.0721);  // Values from "Graphics Shaders: Theory and Practice" by Bailey and Cunningham

struct SingleInputVertexIO
{
    float4 position [[position]];
    float2 textureCoordinate [[user(texturecoord)]];
};

struct TwoInputVertexIO
{
    float4 position [[position]];
    float2 textureCoordinate [[user(texturecoord)]];
    float2 textureCoordinate2 [[user(texturecoord2)]];
};



#endif /* RSCommon_h */
