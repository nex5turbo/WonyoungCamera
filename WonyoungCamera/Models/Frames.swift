//
//  Frames.swift
//  WonyoungCamera
//
//  Created by 워뇨옹 on 3/13/24.
//

import Foundation
import MetalKit

enum Frames: String, CaseIterable {
    case f1
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
