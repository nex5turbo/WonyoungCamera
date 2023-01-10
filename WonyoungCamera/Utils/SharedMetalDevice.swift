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
    var defaultLibrary: MTLLibrary
    init() {
        guard let metalDevice = MTLCreateSystemDefaultDevice() else { fatalError() }
        self.device = metalDevice
        guard let defaultLibrary = device.makeDefaultLibrary() else {
            fatalError("[Error] No command queue for device: \(device)")
        }
        self.defaultLibrary = defaultLibrary
    }
}
