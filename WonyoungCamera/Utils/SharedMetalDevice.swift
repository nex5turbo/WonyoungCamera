//
//  SharedMetalDevice.swift
//  WonyoungCamera
//
//  Created by 워뇨옹 on 2022/09/23.
//

import Foundation
import Metal

class SharedMetalDevice {
    static let instance: SharedMetalDevice = SharedMetalDevice()
    var device: MTLDevice
    init() {
        guard let metalDevice = MTLCreateSystemDefaultDevice() else { fatalError() }
        self.device = metalDevice
    }
}
