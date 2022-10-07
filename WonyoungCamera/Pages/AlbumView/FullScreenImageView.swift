//
//  FullScreenImageView.swift
//  PhotoDiary
//
//  Created by Wonyoung Jang on 2022/08/11.
//

import SwiftUI

struct FullScreenImageView: View {
    @Environment(\.presentationMode) private var presentationMode
    let deviceWidth = UIScreen.main.bounds.width
    @State private var offset: CGSize = .zero
    @State var headerPresent = true
    @State var date: String = ""
    @Binding var paths: [String]
    @Binding var path: String?
    @State var image: UIImage?
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                Image(uiImage: image ?? UIImage())
                    .resizable()
                    .scaledToFit()
                    .frame(width: deviceWidth)
                    .clipped()
                Spacer()
            }
            .onTapGesture {
                withAnimation {
                    headerPresent.toggle()
                }
            }
            .background(.black)
            VStack {
                ZStack {
                    HStack {
                        Button {
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 20))
                        }
                        Spacer()
                    }
                    HStack {
                        Spacer()
                        Text(date)
                        Spacer()
                    }
                }
                .padding()
                .foregroundColor(.white)
                .background(.white.opacity(0.5))
                Spacer()
            }
            .hidden(!headerPresent)
        }
        .offset(y: offset.height)
        .animation(.interactiveSpring(), value: offset)
        .simultaneousGesture(
            DragGesture()
                .onChanged { gesture in
                    if gesture.translation.height <= 0 {
                        return
                    }
                    if gesture.translation.width < 50 {
                        offset = gesture.translation
                    }
                }
                .onEnded { _ in
                    if abs(offset.height) > 100 {
                        presentationMode.wrappedValue.dismiss()
                    } else {
                        offset = .zero
                    }
                }
        )
        .onAppear {
            guard let path = path else {
                presentationMode.wrappedValue.dismiss()
                return
            }
            guard let date = fileCreationDate(at: path) else {
                presentationMode.wrappedValue.dismiss()
                return
            }
            self.image = UIImage(contentsOfFile: path)
            self.date = dateToString(date: date)
        }
    }
}

//struct FullScreenImageView_Previews: PreviewProvider {
//    static var previews: some View {
//        FullScreenImageView()
//    }
//}
func fileCreationDate(at path: String) -> Date? {
    let fileManager = FileManager.default
    guard let attributes = try? fileManager.attributesOfItem(atPath: path) else {
        return nil
    }
    return attributes[.creationDate] as? Date
}
func dateToString(date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    return dateFormatter.string(from: date)
}
