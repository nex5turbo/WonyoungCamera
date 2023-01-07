//
//  ProvidingOperation.swift
//  WonyoungCamera
//
//  Created by 워뇨옹 on 2023/01/07.
//

import Foundation

/// provider가 renderable을 생성하는 작업(operation)입니다.
/// 비동기로 동작하며, 중간에 pause나 stop등 작업관리를 위해 operation으로 생성했습니다.
class ProvidingOperation: AsyncOperation {
    var decorator: Decorator
    let done: (Renderable?) -> Void

    deinit {
        print("[fetch operation] deinit: \(self)")
    }

    init(_ decorator: Decorator,
         done: @escaping (Renderable?) -> Void) {
        self.decorator = decorator
        self.done = done
        super.init()
        print("[fetch operation] init: \(self)")
    }

    public func isSame(_ decorator: Decorator) -> Bool {
        return self.decorator.id == decorator.id
    }

    override func main() {
        self.decorator.provide() { [weak self] (renderable) in
            guard let self = self else {
#if DEBUG
                print("[fetch operation] No self")
#endif
                return
            }
            if self.isCancelled {
                renderable?.finish()
                self.done(nil)
            } else {
                self.done(renderable)
            }
            self.finish()
        }
    }
}
