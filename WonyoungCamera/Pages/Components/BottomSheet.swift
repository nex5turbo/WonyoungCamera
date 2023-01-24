//
//  BottomSheet.swift
//  WonyoungCamera
//
//  Created by 워뇨옹 on 2023/01/24.
//

import SwiftUI

// Drag State
enum DragState {
    case inactive
    case dragging(translation: CGSize)

    var translation: CGSize {
        switch self {
        case .inactive:
            return .zero
        case .dragging(let translation):
            return translation
        }
    }

    var isDragging: Bool {
        switch self {
        case .inactive:
            return false
        case .dragging:
            return true
        }
    }
}

struct BottomSheet<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    @GestureState private var dragState = DragState.inactive
    @Binding var sheetPresent: Bool
    @State var height: CGFloat = 0
    @State var offset: CGFloat = 0

    let content: Content
    let xMarkSize: CGFloat = 24
    let trailingPadding: CGFloat = 16
    let verticalPadding: CGFloat = 14

    private func onDragEnded(drag: DragGesture.Value) {
        offset = 0
        let dragThreshold = height * (2/3)
        if drag.predictedEndTranslation.height > dragThreshold || drag.translation.height > dragThreshold {
            sheetPresent = false
        }
    }
    init(
        sheetPresent: Binding<Bool>,
        @ViewBuilder content: () -> Content
    ) {
        self._sheetPresent = sheetPresent
        self.content = content()
    }

    var body: some View {
        let drag = DragGesture()
         .updating($dragState) { drag, state, _ in
             state = .dragging(translation: drag.translation)
         }
        .onChanged { newValue in
            if newValue.translation.height >= 1 {
                offset = newValue.translation.height
            } else {
                offset = 0
            }
        }
        .onEnded(onDragEnded)

        ZStack {
            if sheetPresent {
                Color.black.opacity(0.1)
                    .onTapGesture {
                        self.sheetPresent = false
                    }
                    .gesture(drag)
            } else {
                Color.clear
            }
            GeometryReader { _ in
                VStack {
                    Spacer()

                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: xMarkSize))
                                .frame(width: xMarkSize, height: xMarkSize, alignment: .center)
                                .foregroundColor(.highlightColor)
                                .padding(.trailing, trailingPadding)
                                .padding(.vertical, verticalPadding)
                                .onTapGesture {
                                    self.sheetPresent = false
                                }
                        }
                        
                        content
                    }
                    .overlay(
                        GeometryReader { contentGeometry in
                            Color.clear
                                .onAppear(perform: {
                                    height = contentGeometry.size.height
                                })
                                .onChange(of: contentGeometry.size) { contentSize in
                                    height = contentSize.height
                                }
                        }
                    )
                    .background(colorScheme == .light ? .white : .black)
                    .frame(height: height)
                    .cornerRadius(15)
                    .offset(
                        y: sheetPresent
                        ?
                        (
                            dragState.isDragging
                            ? offset
                            : 0
                        )
                        : height
                    )
                    .gesture(drag)
                }
            }
        }
        .animation(.spring(), value: dragState.isDragging)
        .animation(.interpolatingSpring(stiffness: 230, damping: 25), value: sheetPresent)
        .edgesIgnoringSafeArea(.bottom)
    }
}
