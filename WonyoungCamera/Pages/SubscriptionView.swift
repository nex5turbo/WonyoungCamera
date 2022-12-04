//
//  SubscriptionView.swift
//  WonyoungCamera
//
//  Created by 워뇨옹 on 2022/12/04.
//

import SwiftUI

struct SubscriptionView: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        VStack {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle")
                }
            }
            .padding()
            Spacer()
            Text("Subscription needed")
            Spacer()
            
        }
    }
}

struct SubscriptionView_Previews: PreviewProvider {
    static var previews: some View {
        SubscriptionView()
    }
}
