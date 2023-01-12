//
//  UserSettings.swift
//  WonyoungCamera
//
//  Created by 워뇨옹 on 2023/01/11.
//

import Foundation

class UserSettings {
    static let instance = UserSettings()
    
    var saveOriginal: Bool
    var shouldWatermark: Bool
    private init() {
        self.saveOriginal = UserDefaults.standard.optionalBool(forKey: "saveOriginal") ?? true
        self.shouldWatermark = UserDefaults.standard.optionalBool(forKey: "shouldWatermark") ?? true
    }
    func setSaveOriginal(to value: Bool) {
        self.saveOriginal = value
        UserDefaults.standard.set(saveOriginal, forKey: "saveOriginal")
    }
    func setShouldWatermark(to value: Bool) {
        self.shouldWatermark = value
        UserDefaults.standard.set(shouldWatermark, forKey: "shouldWatermark")
    }
}

extension UserDefaults {
    public func optionalInt(forKey defaultName: String) -> Int? {
        let defaults = self
        if let value = defaults.value(forKey: defaultName) {
            return value as? Int
        }
        return nil
    }

    public func optionalBool(forKey defaultName: String) -> Bool? {
        let defaults = self
        if let value = defaults.value(forKey: defaultName) {
            return value as? Bool
        }
        return nil
    }
}
