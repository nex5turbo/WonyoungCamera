//
//  TabBar.swift
//  WonyoungCamera
//
//  Created by 워뇨옹 on 2023/02/06.
//

import SwiftUI

struct TabBar: View {
    let items: [String]
    @Binding var selectedIndex: Int

    private let fontSize: CGFloat = 14
    private let padding: CGFloat = 16

    init(items: [String], selectedIndex: Binding<Int>) {
        self.items = items
        self._selectedIndex = selectedIndex
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(.highlightColor)
        UISegmentedControl
            .appearance()
            .setTitleTextAttributes(
                [
                    .font: UIFont.systemFont(ofSize: fontSize, weight: .semibold),
                    .foregroundColor: UIColor.white
                ],
                for: .selected
            )
        UISegmentedControl
            .appearance()
            .setTitleTextAttributes(
                [
                    .font: UIFont.systemFont(ofSize: fontSize, weight: .semibold),
                    .foregroundColor: UIColor(.white)
                ],
                for: .normal
            )
    }
    var body: some View {
        Picker(selection: $selectedIndex, label: Text("")) {
            ForEach(items.indices, id: \.self) { index in
                Text(items[index])
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.horizontal, padding)
    }
}

struct TabBar_Previews: PreviewProvider {
    static let items: [String] = ["Layout", "Margin", "Border", "Padding"]
    @State static var selectedIndex: Int = 0
    static var previews: some View {
        TabBar(items: items, selectedIndex: $selectedIndex)
    }
}
