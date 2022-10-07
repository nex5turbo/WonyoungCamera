//
//  Hidden.swift
//  PhotoDiary
//
//  Created by 내꺼 on 2022/08/05.
//

import SwiftUI

extension View {
    @ViewBuilder func hidden(_ shouldHide: Bool) -> some View {
        if shouldHide {
            self.frame(width: 0, height: 0).hidden()
        } else {
            self
        }
    }
}
