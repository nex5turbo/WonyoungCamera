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
    case a12, a13, a14, a15, a16, a17, a18, a19, a20
    case a21, a22, a23, a24, a25, a26, a27, a28, a29, a30
    case a31
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
