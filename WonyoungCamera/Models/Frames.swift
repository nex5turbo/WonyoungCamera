//
//  Frames.swift
//  WonyoungCamera
//
//  Created by 워뇨옹 on 3/13/24.
//

import Foundation
import MetalKit

enum Frames: String, CaseIterable {
    case insta1, insta2, insta3
    case flower1, flower2
    case neon1, neon2, neon3, neon4, neon5, neon6, neon7
    case sketch1
    
    case f1, f2, f3, f5, f6, f10, f11, f13, f14, f15
}

class FramesStorage {
    static var instance = FramesStorage()
    let device: MTLDevice
    
    init() {
        self.device = SharedMetalDevice.instance.device
    }
    
    func getTexture(_ name: String) -> MTLTexture? {
        guard let texture = device.loadFilter(filterName: name, ext: "png") else {
            return nil
        }
        return texture
    }
}
