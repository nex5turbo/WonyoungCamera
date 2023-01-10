//
//  SettingView.swift
//  WonyoungCamera
//
//  Created by Wonyoung Jang on 2023/01/06.
//

import SwiftUI
import StoreKit
import MessageUI

struct SettingView: View {
    // Subscription
    @ObservedObject private var purchaseManager = PurchaseManager.shared

    // Contact
    @State var result: Result<MFMailComposeResult, Error>?
    @State var presentMailView = false
    @State var presentMailFailure = false
    @State var hapticEnabled = true
    @State var saveOriginal = true

    var body: some View {
        List {
            if !purchaseManager.isPremiumUser {
                Section(String.subscribeLabel) {
                    Button {
                        DispatchQueue.main.async {
                            purchaseManager.subscriptionViewPresent.toggle()
                        }
                    } label: {
                        Text(String.subscribeLabel)
                    }
                }
            }

            Section("Settings") {
                Toggle(isOn: $hapticEnabled) {
                    Text("Haptic")
                }
                .onChange(of: hapticEnabled, perform: { newValue in
                    HapticManager.instance.toggleHaptic(to: newValue)
                })
                .onAppear {
                    self.hapticEnabled = HapticManager.instance.hapticEnabled
                }
                Toggle(isOn: $saveOriginal) {
                    Text("Save Original Photo")
                }
                .onChange(of: saveOriginal) { newValue in
                    UserSettings.instance.setSaveOriginal(to: newValue)
                }
                .onAppear {
                    self.saveOriginal = UserSettings.instance.saveOriginal
                }
            }
            Section("About") {
                Button {
                    guard let currentScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
                        return
                    }
                    SKStoreReviewController.requestReview(in: currentScene)
                } label: {
                    Text("Rate")
                }

                Button {
                    if MFMailComposeViewController.canSendMail() {
                        presentMailView = true
                    } else {
                        presentMailFailure = true
                    }
                } label: {
                    Text("Contact")
                }
                .sheet(isPresented: $presentMailView) {
                    MailView(
                        isShowing: $presentMailView,
                        result: $result,
                        subject: "Feedback on Rounder Camera",
                        recipients: ["nex5turbo@gmail.com"]
                    )
                }
                .alert("Your mail is not registered", isPresented: $presentMailFailure) {
                    Button(String.cancelLabel, role: .cancel) {}
                }

                Button {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                } label: {
                    Text("View App Permissions")
                }

                Link("Data Privacy", destination: URL(string: "https://sites.google.com/view/rounderprivacy/")!)
            }

            Section("VERSION") {
                HStack {
                    Text("1.0.1")
                    Spacer()
                }
                .contentShape(Rectangle())
            }
        }
        .navigationTitle("Rounder Setting")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}

// Ref.: https://stackoverflow.com/questions/56784722/swiftui-send-email
struct MailView: UIViewControllerRepresentable {
    @Binding var isShowing: Bool
    @Binding var result: Result<MFMailComposeResult, Error>?

    let subject: String
    let recipients: [String]

    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {

        @Binding var isShowing: Bool
        @Binding var result: Result<MFMailComposeResult, Error>?

        init(isShowing: Binding<Bool>,
             result: Binding<Result<MFMailComposeResult, Error>?>) {
            _isShowing = isShowing
            _result = result
        }

        func mailComposeController(_ controller: MFMailComposeViewController,
                                   didFinishWith result: MFMailComposeResult,
                                   error: Error?) {
            defer {
                isShowing = false
            }
            guard error == nil else {
                self.result = .failure(error!)
                return
            }
            self.result = .success(result)
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(isShowing: $isShowing,
                           result: $result)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<MailView>) -> MFMailComposeViewController {
        let viewController = MFMailComposeViewController()
        viewController.mailComposeDelegate = context.coordinator
        viewController.setSubject(subject)
        viewController.setToRecipients(recipients)

        return viewController
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController,
                                context: UIViewControllerRepresentableContext<MailView>) {

    }
}
