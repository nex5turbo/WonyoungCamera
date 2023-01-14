//
//  UserSettings.swift
//  WonyoungCamera
//
//  Created by 워뇨옹 on 2023/01/11.
//

import Foundation
extension String {
    static let saveOriginalKey = "saveOriginal"
    static let removeWatermarkKey = "removeWatermark"
    static let hapticKey = "haptic"
}
class UserSettings {
    static let instance = UserSettings()
    
    var saveOriginal: Bool
    var removeWatermark: Bool
    private init() {
        self.saveOriginal = UserDefaults.standard.optionalBool(forKey: .saveOriginalKey) ?? true
        self.removeWatermark = UserDefaults.standard.optionalBool(forKey: .removeWatermarkKey) ?? false
    }
    func setSaveOriginal(to value: Bool) {
        self.saveOriginal = value
        UserDefaults.standard.set(saveOriginal, forKey: .saveOriginalKey)
    }
    func setRemoveWatermark(to value: Bool) {
        self.removeWatermark = value
        UserDefaults.standard.set(removeWatermark, forKey: .removeWatermarkKey)
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
