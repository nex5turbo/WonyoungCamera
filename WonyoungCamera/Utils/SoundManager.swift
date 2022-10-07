//
//  SoundManager.swift
//  YoungsCamera
//
//  Created by 워뇨옹 on 2022/08/25.
//

import AVFoundation

func shutterSound() {
    //1002 1012 1106
    let systemSoundID: SystemSoundID = 1108
    AudioServicesPlaySystemSound(systemSoundID)
}
