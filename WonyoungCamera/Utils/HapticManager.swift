//
//  HapticManager.swift
//  YoungsCamera
//
//  Created by 워뇨옹 on 2022/08/25.
//

import Foundation
import UIKit

class HapticManager {
    
    static let instance = HapticManager()
    private var hapticEnabled: Bool
    init() {
        self.hapticEnabled = UserDefaults.standard.bool(forKey: "haptic")
    }
    
    func toggleHaptic() {
        self.hapticEnabled.toggle()
        UserDefaults.standard.set(hapticEnabled, forKey: "haptic")
    }
    
    func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
    
    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        if hapticEnabled {
            let generator = UIImpactFeedbackGenerator(style: style)
            generator.impactOccurred()
        }
    }
}
