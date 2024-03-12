//
//  FilterScrollView.swift
//  YoungsCamera
//
//  Created by 워뇨옹 on 2022/08/24.
//

import SwiftUI

struct FilterScrollView: View {
    @ObservedObject var purchaseManager = InAppPurchaseManager.shared
    @ObservedObject var filterManager = FilterManager.shared
    @Binding var decoration: Decoration
    @State var test: String? = ""

    @State var isRotating = false
    var foreverAnimation: Animation {
        Animation.linear(duration: 5.0)
            .repeatForever(autoreverses: false)
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            ScrollViewReader { value in
                HStack {
                    Section {
                        ForEach(filterManager.filters, id: \.name) { filter in
                            if let image = filterManager.sampleImages[filter.name] {
                                VStack {
                                    HapticButton {
                                        self.filterManager.selectedFilter = filter
                                    } content: {
                                        ZStack {
                                            Image(uiImage: image!)
                                                .resizable()
                                                .scaledToFill()
                                                .clipShape(Circle())
                                                .frame(width: 40, height: 40)
                                            Group {
                                                self.filterManager.selectedFilter == filter
                                                ? Color.black.opacity(0.7)
                                                : Color.clear
                                            }
                                            .frame(width: 40, height: 40)
                                            GradientView {
                                                Image(systemName: "checkmark.circle")
                                                    .resizable()
                                                    .frame(width: 40, height: 40)
                                                    .opacity(self.filterManager.selectedFilter == filter ? 1 : 0)
                                            }
                                        }
                                    }

                                    VStack {
                                        Text(filter.name)
                                            .frame(width: 30)
                                            .font(.system(size: 10))
                                            .scaledToFill()
                                            .minimumScaleFactor(0.5)
                                            .lineLimit(1)
                                            .foregroundColor(.white)
                                    }
                                    .frame(height: 20)
                                }
                            }
                        }
                    } header: {
                        if !purchaseManager.isPremiumUser {
                            VStack {
                                Button {
                                    purchaseManager.subscriptionViewPresent.toggle()
                                } label: {
                                    Image("subIcon")
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                        .rotationEffect(Angle(degrees: isRotating ? 360 : 0))
                                        .animation(foreverAnimation, value: isRotating)
                                        .onAppear {
                                            isRotating = true
                                        }
                                }
                                
                                VStack {
                                    GradientView {
                                        Text("Subscribe")
                                            .frame(width: 30)
                                            .font(.system(size: 10, weight: .bold))
                                            .scaledToFill()
                                            .minimumScaleFactor(0.5)
                                            .lineLimit(1)
                                    }
                                }
                                .frame(height: 20)
                            }
                            .background(.black)
                        }
                    }
                }
                .onChange(of: filterManager.selectedFilter) { newValue in
                    guard let newValue else {
                        return
                    }
                    let scrollArray = filterManager.filters
                    guard let index = scrollArray.firstIndex(of: newValue) else {
                        return
                    }
                    withAnimation {
                        value.scrollTo(Int(index), anchor: .center)
                    }
                }
            }
        }
    }
}

struct FilterScrollView_Previews: PreviewProvider {
    static var previews: some View {
        FilterScrollView(decoration: .constant(.empty()))
    }
}
