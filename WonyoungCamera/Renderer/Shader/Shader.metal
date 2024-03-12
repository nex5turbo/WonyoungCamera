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

fragment half4 default_fragment(RasterizerData in [[ stage_in ]],
                                texture2d<half> inputTexture [[texture(0)]],
                                constant float &deviceWidth [[ buffer(0) ]],
                                constant float &deviceHeight [[ buffer(1) ]]) {
    constexpr sampler colorSampler(address::clamp_to_zero ,coord::normalized, filter::linear);
    
    float2 size = float2(deviceWidth, deviceHeight);
    
    float2 center = float2(size.x / 2, (size.y / 2));
    float2 circleCoord = float2(in.position.x / size.x, (in.position.y - center.y + (size.x / 2)) / size.x);
    half4 circleColor = inputTexture.sample(colorSampler, circleCoord);
    return circleColor;
}


float2 squareToCircle(float2 uv, float2 center, float radius) {
    float2 centerUV = float2(0.5, 0.5); // 텍스처 중심
    
    // 중심을 기준으로 uv 좌표 변환
    float2 delta = uv - centerUV;
    float distance = length(delta);
    
    // 중심에서 거리가 radius를 넘어가는 경우, 원 밖에 있는 부분은 제거
    if (distance > radius) {
        return float2(-1.0); // 텍스처 바깥에 있는 부분은 (-1, -1) 반환
    }
    
    // 원 안에 있는 부분의 좌표를 계산
    float2 circleUV = centerUV + delta * (sqrt(radius * radius - distance * distance) / distance);
    return circleUV;
}

fragment half4 rounding_fragment(RasterizerData in [[stage_in]],
                                 texture2d<half> textureIn [[texture(0)]],
                                 texture2d<half> backgroundTexture [[texture(1)]],
                                 constant bool &hasBG [[ buffer(0) ]],
                                 constant float &ratio [[ buffer(1) ]]) {
    constexpr float radius = 0.45; // 반지름은 텍스처의 크기의 절반
    constexpr sampler colorSampler(address::clamp_to_zero ,coord::normalized, filter::linear);
    
    // 정사각형 좌표를 원 좌표로 변환
    float2 circleUV = squareToCircle(in.textureCoordinate, float2(0.5), radius);
    
    // 원 밖에 있는 부분은 투명하게 처리
    if (circleUV.x < 0.0 || circleUV.y < 0.0) {
        if (hasBG) {
            return backgroundTexture.sample(colorSampler, in.textureCoordinate);
        } else {
            return half4(0.0, 0.0, 0.0, 0.0); // 투명한 색상 반환
        }
    }
    float y = in.textureCoordinate.y;
    y = y - 0.5;
    y = y * (ratio);
    y = y + 0.5;
    // 텍스처에서 해당 좌표에 있는 색상을 샘플링하여 반환
    return textureIn.sample(colorSampler, float2(in.textureCoordinate.x, y));
}
