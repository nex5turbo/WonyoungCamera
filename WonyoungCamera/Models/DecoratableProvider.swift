//
//  DecoratableProvider.swift
//  WonyoungCamera
//
//  Created by 워뇨옹 on 2023/01/07.
//

import Foundation
import Metal

class DecoratableProvider {
    private var cacheMap: [String: Decoratable] = [:]
    
    func getDecorationOrFetch() -> MTLTexture? {
        return nil
    }
}
