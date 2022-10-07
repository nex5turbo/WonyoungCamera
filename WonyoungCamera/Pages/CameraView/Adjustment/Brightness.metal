//
//  Brightness.metal
//  WonyoungCamera
//
//  Created by 워뇨옹 on 2022/09/24.
//

#include <metal_stdlib>
using namespace metal;

kernel void applyLut(texture2d<half, access::write> writeTexture [[ texture(0) ]],
                          texture2d<half> readTexture [[ texture(1) ]],
                          texture2d<half> lutTexture [[ texture(2) ]],
                          uint2 gid [[ thread_position_in_grid ]]) {
    
    
}
