//
//  Backgrounds.swift
//  WonyoungCamera
//
//  Created by 워뇨옹 on 2023/02/06.
//

import Foundation
import MetalKit

enum Backgrounds: String, CaseIterable {
    case a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11
}

class BackgroundsStorage {
    static var instance = BackgroundsStorage()
    let device: MTLDevice
    
    init() {
        self.device = SharedMetalDevice.instance.device
    }

    func getTexture(_ name: String) -> MTLTexture? {
        guard let texture = device.loadFilter(filterName: name, ext: "jpg") else { return nil }
        return texture
    }
}
