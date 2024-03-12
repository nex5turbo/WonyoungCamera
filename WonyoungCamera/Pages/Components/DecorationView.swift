//
//  DecorationView.swift
//  WonyoungCamera
//
//  Created by 워뇨옹 on 2023/02/06.
//

import SwiftUI

struct DecorationView: View {
    private enum TabType: Int {
        case outline
        case background
        case frame
    }
    @Binding var decoration: Decoration
    @State var selectedTabIndex = 0
    var body: some View {
        TabBar(items: ["Outline", "Background", "Frame"], selectedIndex: $selectedTabIndex)
        let selectedTab = TabType(rawValue: selectedTabIndex) ?? TabType.outline
        ZStack {
            BorderAdjustView(decoration: $decoration)
                .opacity(selectedTab == .outline ? 1 : 0)
            BackgroundView(decoration: $decoration)
                .opacity(selectedTab == .background ? 1 : 0)
            FrameView(decoration: $decoration)
                .opacity(selectedTab == .frame ? 1 : 0)
        }
    }
}

//struct DecorationView_Previews: PreviewProvider {
//    static var previews: some View {
//        DecorationView()
//    }
//}
