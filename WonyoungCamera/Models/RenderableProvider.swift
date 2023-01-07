//
//  RenderableProvider.swift
//  WonyoungCamera
//
//  Created by 워뇨옹 on 2023/01/07.
//

import Foundation
import Metal

class RenderableProvider {
    private var cacheMap = ConcurrentDictionary<String, Renderable>()
    private var operationQueue: OperationQueue = {
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 8
        return operationQueue
    }()
    
    deinit {
        stop()
    }

    public func stop() {
        operationQueue.cancelAllOperations()
        /*
         operationQueue.maxConcurrentOperationCount = 0 을 없애면
         stop 이후에 enqueue가 호출되고 gif, video 같은 renderable이 살아 있을 수 있는 여지가 있습니다.
         operationQueue.maxConcurrentOperationCount = 0 을 사용한다면
         TODO: cancel 요청된 이후 마무리 작업을 하지 못해 operation이 쌓이게 되어 memory leak이 발생하여 해결해야 합니다.
         
         현재는 renderable이 계속 도는 것보다 operation leak이 낫다고 판단됩니다.
         */
        operationQueue.maxConcurrentOperationCount = 0
        cacheMap.removeAll()
    }
    
    func getRenderableOrFetch(_ decorator: Decorator) -> Renderable? {
        guard let renderable = cacheMap[decorator.id] else {
            enqueue(decorator)
            return nil
        }
        return renderable
    }

    private func isInQueue(_ decorator: Decorator) -> Bool {
        for operation in operationQueue.operations {
            guard let operation = operation as? ProvidingOperation else { continue }
            if operation.isSame(decorator) { return true }
        }
        return false
    }

    private func enqueue(_ decorator: Decorator) {
        guard isInQueue(decorator) == false else { return }
        let operation = ProvidingOperation(decorator) { [weak self] (renderable) in
            guard let self = self else { return }
            self.set(renderable, key: decorator.id)
        }
        operationQueue.addOperation(operation)
    }
    
    public func set(_ renderable: Renderable?, key: String) {
        cacheMap[key] = renderable
    }
}
