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
    private var operationQueue: OperationQueue = {
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 8
        return operationQueue
    }()
    
    func getRenderableOrFetch(_ decorator: Decorator) -> Renderable? {
        guard let renderable = cacheMap[decorator.id] else {
            return nil
        }
        return renderable
    }
    func setRenderable() {
        
    }
    
    private func isInQueue(_ decorator: Decorator) -> Bool {
        for operation in operationQueue.operations {
            guard let operation = operation as? ProvidingOperation else { continue }
            if operation.isSame(decorator) { return true }
        }
        return false
    }

    /// 같은 operation이 있다면 enqueue하지 않는다.
    private func enqueue(_ decorator: Decorator) {
        guard isInQueue(decorator) == false else { return }
        let operation = ProvidingOperation(decorator) { [weak self] (renderable) in
            guard let self = self else { return }
            // 현재는 renderable이 nil인 경우에도 set 해주고 있습니다. 이것이 추후 문제가 된다면 수정되어야 할 수도 있습니다.
            self.set(renderable, key: decorator.id)
        }
        operationQueue.addOperation(operation)
    }
    
    public func set(_ renderable: Renderable?, key: String) {
        cacheMap[key] = renderable
    }
}
