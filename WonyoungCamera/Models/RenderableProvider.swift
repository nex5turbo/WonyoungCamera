//
//  RenderableProvider.swift
//  WonyoungCamera
//
//  Created by 워뇨옹 on 2023/01/07.
//

import Foundation
import Metal

class RenderableProvider {
    private var cacheMap: [String: Renderable] = [:]
    
    func getRenderableOrFetch(_ decorator: Decorator) -> Renderable? {
        return cacheMap[decorator.path]
    }
}

protocol Decorator {
    var path: String { get }
}
