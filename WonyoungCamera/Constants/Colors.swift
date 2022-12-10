//
//  Colors.swift
//  WonyoungCamera
//
//  Created by 워뇨옹 on 2022/11/03.
//

import SwiftUI

extension Color {
    static let highlightColor = Color(uiColor: UIColor(named: "HighlightColor")!)
    static let mainGradientColor = LinearGradient(colors: [
        Color(red: 160 / 255.0, green: 214 / 255.0, blue: 251 / 255),
        Color(red: 207 / 255.0, green: 129 / 255.0, blue: 245 / 255.0)],
                                          startPoint: .leading,
                                          endPoint: .trailing
    )
}
