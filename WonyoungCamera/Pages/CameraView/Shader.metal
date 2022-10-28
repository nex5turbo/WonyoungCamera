//
//  Shader.metal
//  PhotoDiary
//
//  Created by 워뇨옹 on 2022/08/17.
//

#include <metal_stdlib>
using namespace metal;


typedef enum VertexInputIndex
{
    VertexInputIndexVertices     = 0,
    VertexInputIndexViewportSize = 1,
} VertexInputIndex;

// Texture index values shared between shader and C code to ensure Metal shader buffer inputs match
//   Metal API texture set calls
typedef enum TextureIndex
{
    TextureIndexBaseColor = 0,
} TextureIndex;

//  This structure defines the layout of each vertex in the array of vertices set as an input to the
//    Metal vertex shader.  Since this header is shared between the .metal shader and C code,
//    you can be sure that the layout of the vertex array in the code matches the layout that
//    the vertex shader expects

typedef struct
{
    // Positions in pixel space. A value of 100 indicates 100 pixels from the origin/center.
    vector_float2 position;

    // 2D texture coordinate
    vector_float2 textureCoordinate;
} Vertex;

struct RasterizerData {
    float4 position [[position]];
    float2 textureCoordinate;
};

struct VertexOut {
    float4 position [[ position ]];
};

vertex RasterizerData default_vertex(
                                 uint vertexID [[ vertex_id ]],
                                 constant Vertex *vertexArray [[ buffer(0) ]]) {
    RasterizerData out;
    float2 pixelSpacePosition = vertexArray[vertexID].position.xy;
    out.position = vector_float4(0,0,0,1);
    out.position.xy = pixelSpacePosition;
    out.textureCoordinate = vertexArray[vertexID].textureCoordinate;
    
    return out;
}
half4 gaussianBlur(float2 coord, texture2d<half> texture);

fragment half4 default_fragment(RasterizerData in [[ stage_in ]],
                                texture2d<half> inputTexture [[texture(0)]],
                                texture2d<half> cameraTexture [[ texture(1) ]],
                                constant bool &shouldFlip [[ buffer(0) ]],
                                constant float &deviceWidth [[ buffer(1) ]],
                                constant float &deviceHeight [[ buffer(2) ]],
                                constant float &deviceScale [[ buffer(3) ]],
                                constant bool &shouldFilter [[ buffer(4) ]]) {
    constexpr sampler colorSampler(coord::normalized, filter::linear);
    float frameRatio = float(cameraTexture.get_height()) / float(cameraTexture.get_width());
    float2 size = float2(deviceWidth * deviceScale, deviceHeight * deviceScale);
    float2 frameSize = float2(deviceWidth * deviceScale, deviceWidth * frameRatio * deviceScale);
    float2 center = float2(size.x / 2, (size.y / 2) - 200);
    float2 circleCoord = float2(in.position.x / size.x, (in.position.y - center.y + (size.x / 2)) / size.x);
    float2 frameCoord = float2(in.position.x / frameSize.x, (in.position.y - center.y + (frameSize.y / 2)) / frameSize.y);
    half4 circleColor = inputTexture.sample(colorSampler, circleCoord);
    if (circleColor.a == 0) {
//        half4 testColor = gaussianBlur(in.textureCoordinate, cameraTexture);
//        return mix(testColor, half4(0, 0, 0, 1), 0.5);
        return cameraTexture.sample(colorSampler, frameCoord);
    } else {
        return circleColor;
    }
}

half4 gaussianBlur(float2 coord, texture2d<half> texture) {
    constexpr sampler qsampler(coord::normalized,
                               address::clamp_to_edge);
    float2 offset = coord;
    float width = texture.get_width();
    float height = texture.get_width();
    float xPixel = (1 / width) * 3;
    float yPixel = (1 / height) * 2;
    
    
    half3 sum = half3(0.0, 0.0, 0.0);
    
    
    // code from https://github.com/mattdesl/lwjgl-basics/wiki/ShaderLesson5
    
    // 9 tap filter
    sum += texture.sample(qsampler, float2(offset.x - 4.0*xPixel, offset.y - 4.0*yPixel)).rgb * 0.0162162162;
    sum += texture.sample(qsampler, float2(offset.x - 3.0*xPixel, offset.y - 3.0*yPixel)).rgb * 0.0540540541;
    sum += texture.sample(qsampler, float2(offset.x - 2.0*xPixel, offset.y - 2.0*yPixel)).rgb * 0.1216216216;
    sum += texture.sample(qsampler, float2(offset.x - 1.0*xPixel, offset.y - 1.0*yPixel)).rgb * 0.1945945946;
    
    sum += texture.sample(qsampler, offset).rgb * 0.2270270270;
    
    sum += texture.sample(qsampler, float2(offset.x + 1.0*xPixel, offset.y + 1.0*yPixel)).rgb * 0.1945945946;
    sum += texture.sample(qsampler, float2(offset.x + 2.0*xPixel, offset.y + 2.0*yPixel)).rgb * 0.1216216216;
    sum += texture.sample(qsampler, float2(offset.x + 3.0*xPixel, offset.y + 3.0*yPixel)).rgb * 0.0540540541;
    sum += texture.sample(qsampler, float2(offset.x + 4.0*xPixel, offset.y + 4.0*yPixel)).rgb * 0.0162162162;
    
    half4 adjusted;
    adjusted.rgb = sum;
//    adjusted.g = color.g;
    adjusted.a = 1;
    return adjusted;
}
