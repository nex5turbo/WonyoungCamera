//
//  Colors.swift
//  WonyoungCamera
//
//  Created by 워뇨옹 on 2022/11/03.
//

import SwiftUI

extension Color {
    static let highlightColor = Color(uiColor: UIColor(named: "HighlightColor")!)
    static let bottomSheetColor = Color(red: 30 / 255.0, green: 30 / 255.0, blue: 30 / 255.0)
    static let mainGradientColor = LinearGradient(colors: [
        Color(red: 160 / 255.0, green: 214 / 255.0, blue: 251 / 255),
        Color(red: 207 / 255.0, green: 129 / 255.0, blue: 245 / 255.0)],
                                          startPoint: .leading,
                                          endPoint: .trailing
    )
    static let defaultColors: [Color] = [
        Color(#colorLiteral(red: 0.0, green: 0.0, blue: 0.0, alpha: 1)), Color(#colorLiteral(red: 0.263, green: 0.369, blue: 0.537, alpha: 1)), Color(#colorLiteral(red: 0.22, green: 0.4, blue: 1, alpha: 1)), Color(#colorLiteral(red: 0.475, green: 0.596, blue: 1, alpha: 1)), Color(#colorLiteral(red: 0.0, green: 0.588, blue: 0.522, alpha: 1)), Color(#colorLiteral(red: 0.357, green: 0.851, blue: 0.698, alpha: 1)), Color(#colorLiteral(red: 0.231, green: 0.816, blue: 0.275, alpha: 1)), Color(#colorLiteral(red: 1, green: 0.914, blue: 0.435, alpha: 1)),
        Color(#colorLiteral(red: 1, green: 0.922, blue: 0.0, alpha: 1)), Color(#colorLiteral(red: 1, green: 0.718, blue: 0.263, alpha: 1)), Color(#colorLiteral(red: 1, green: 0.525, blue: 0.871, alpha: 1)), Color(#colorLiteral(red: 1, green: 0.212, blue: 0.212, alpha: 1)), Color(#colorLiteral(red: 0.808, green: 0.11, blue: 0.11, alpha: 1)), Color(#colorLiteral(red: 0.769, green: 0.329, blue: 0.004, alpha: 1)), Color(#colorLiteral(red: 0.769, green: 0.592, blue: 0.004, alpha: 1)), Color(#colorLiteral(red: 0.588, green: 0.455, blue: 0.0, alpha: 1)),
        Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)), Color(#colorLiteral(red: 0.925, green: 0.925, blue: 0.925, alpha: 1)), Color(#colorLiteral(red: 0.776, green: 0.776, blue: 0.776, alpha: 1)), Color(#colorLiteral(red: 0.588, green: 0.588, blue: 0.588, alpha: 1)), Color(#colorLiteral(red: 0.365, green: 0.365, blue: 0.365, alpha: 1)), Color(#colorLiteral(red: 0.757, green: 0.773, blue: 0.922, alpha: 1)), Color(#colorLiteral(red: 0.757, green: 0.922, blue: 0.827, alpha: 1)), Color(#colorLiteral(red: 0.937, green: 0.957, blue: 0.733, alpha: 1)),
        Color(#colorLiteral(red: 0.957, green: 0.878, blue: 0.733, alpha: 1)), Color(#colorLiteral(red: 0.98, green: 0.957, blue: 0.929, alpha: 1)), Color(#colorLiteral(red: 0.984, green: 0.91, blue: 1, alpha: 1)), Color(#colorLiteral(red: 0.957, green: 0.769, blue: 0.733, alpha: 1)), Color(#colorLiteral(red: 0.886, green: 0.824, blue: 0.824, alpha: 1)), Color(#colorLiteral(red: 0.941, green: 0.902, blue: 0.871, alpha: 1)), Color(#colorLiteral(red: 0.878, green: 0.863, blue: 0.812, alpha: 1)), Color(#colorLiteral(red: 0.961, green: 0.953, blue: 0.918, alpha: 1))
    ]
}
