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
                                constant float &deviceWidth [[ buffer(0) ]],
                                constant float &deviceHeight [[ buffer(1) ]]) {
    constexpr sampler colorSampler(coord::normalized, filter::linear);
    
    float2 size = float2(deviceWidth, deviceHeight);
    
    float2 center = float2(size.x / 2, (size.y / 2));
    float2 circleCoord = float2(in.position.x / size.x, (in.position.y - center.y + (size.x / 2)) / size.x);
    half4 circleColor = inputTexture.sample(colorSampler, circleCoord);
    return circleColor;
}
