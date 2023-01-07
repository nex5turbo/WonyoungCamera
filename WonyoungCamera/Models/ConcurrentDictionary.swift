//
//  ConcurrentDictionary.swift
//  WonyoungCamera
//
//  Created by 워뇨옹 on 2023/01/08.
//

import Foundation

final class ConcurrentDictionary<KeyType: Hashable, ValueType> {

    private let semaphore = DispatchSemaphore(value: 1)
    private var internalMap: [KeyType: ValueType] = [:]

    var count: Int {
        semaphore.wait()
        let count = internalMap.count
        semaphore.signal()
        return count
    }

    func removeValue(forKey key: KeyType) {
        semaphore.wait()
        internalMap.removeValue(forKey: key)
        semaphore.signal()
    }

    func remove(excluding keys: Set<KeyType>) {
        semaphore.wait()
        internalMap.forEach { (key, _) in
            if keys.contains(key) { return }
            internalMap.removeValue(forKey: key)
        }
        semaphore.signal()
    }

    func removeAll() {
        semaphore.wait()
        internalMap.removeAll()
        semaphore.signal()
    }

    func forEach(_ body: (Dictionary<KeyType, ValueType>.Element) throws -> Void) rethrows {
        semaphore.wait()
        try internalMap.forEach(body)
        semaphore.signal()
    }

    subscript(key: KeyType) -> ValueType? {
        get {
            var value: ValueType?
            semaphore.wait()
            value = internalMap[key]
            semaphore.signal()
            return value
        }
        set {
            setValue(value: newValue, forKey: key)
        }
    }

    func setValue(value: ValueType?, forKey key: KeyType) {
        semaphore.wait()
        internalMap[key] = value
        semaphore.signal()
    }

    func withInternalMap(_ callback: ([KeyType: ValueType]) -> Void) {
        semaphore.wait()
        callback(internalMap)
        semaphore.signal()
    }

    func modifyValue(forKey key: KeyType, _ callback: (_ oldValue: ValueType?) -> ValueType?) {
        semaphore.wait()
        let oldValue = internalMap[key]
        internalMap[key] = callback(oldValue)
        semaphore.signal()
    }
}
