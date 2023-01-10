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
    private init() {
        self.saveOriginal = UserDefaults.standard.bool(forKey: "saveOriginal")
    }
    func setSaveOriginal(to value: Bool) {
        self.saveOriginal = value
        UserDefaults.standard.set(saveOriginal, forKey: "saveOriginal")
    }
}
