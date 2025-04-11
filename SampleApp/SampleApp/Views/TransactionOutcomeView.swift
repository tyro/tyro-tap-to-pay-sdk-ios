//
//  TransactionOutcomeView.swift
//  SampleApp
//
//  Created by Sanjay Narayana on 1/5/2024.
//

import Foundation
import SwiftUI
import TyroTapToPaySDK

struct TransactionOutcomeView: View {
  private var transactionOutcome: TransactionOutcome
  private var tapToPaySdk: TyroTapToPay
  @State private var viewModel = ViewModel()

  init(_ transactionOutcome: TransactionOutcome, _ tapToPaySdk: TyroTapToPay) {
    self.transactionOutcome = transactionOutcome
    self.tapToPaySdk = tapToPaySdk
  }

  var body: some View {
    Group {
      Spacer()

      Group {
        Image(systemName: "checkmark.circle.fill")
          .resizable()
          .frame(maxWidth: 75, maxHeight: 75)
        Text(transactionOutcome.statusMessage)
          .font(.title3)
          .multilineTextAlignment(.center)
        Text("Outcome: \(transactionOutcome.statusCode)")
          .font(.title3)
          .multilineTextAlignment(.center)
      }
      .foregroundStyle(transactionOutcome.statusCode == "APPROVED" ? .green : .red)

      Button {
        viewModel.showSheet = true
      } label: {
        Text("Receipt")
          .frame(maxWidth: .infinity, minHeight: 40)
          .font(.title3)
      }
      .padding()
      .sheet(isPresented: $viewModel.showSheet) {
        NavigationView {
          List {
            Text(transactionOutcome.customerReceipt)
              .foregroundStyle(.gray)
              .monospaced()
              .padding()
              .fixedSize()

            Section {
              TextField("Email", text: $viewModel.email, prompt: Text("email"))
                .textCase(.lowercase)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
              Button {
                Task {
                  try await viewModel.sendReceiptRequest(
                    tapToPaySdk: tapToPaySdk,
                    transactionId: transactionOutcome.transactionID,
                    email: viewModel.email
                  )
                }
              } label: {
                Text("Send receipt")
                  .frame(maxWidth: .infinity, minHeight: 35)
              }
              .buttonStyle(.borderedProminent)
              .disabled(!viewModel.isValidEmail() || viewModel.isLoading)
            }.alert(
              isPresented: $viewModel.showAlert,
              content: {
                Alert(
                  title: Text("Receipt"),
                  message: Text(viewModel.emailSentText),
                  dismissButton: .default(Text("Close")))
              })
          }.navigationBarTitle("Receipt", displayMode: .inline)
        }
      }

      Spacer()
    }
  }
}

extension TransactionOutcomeView {
  @Observable
  class ViewModel: ObservableObject {
    var showSheet = false
    var email = ""
    var isLoading = false
    var showAlert = false
    var emailSentText = ""

    func isValidEmail() -> Bool {
      let inputEmail = self.email
      do {
        let emailRegex = try Regex("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$")
        return inputEmail.contains(emailRegex)
      } catch {
        return false
      }
    }

    func sendReceiptRequest(tapToPaySdk: TyroTapToPay, transactionId: String, email: String)
      async throws
    {
      isLoading = true
      do {
        let requestSent = try await tapToPaySdk.requestDigitalReceipt(
          transactionId: transactionId,
          email: email
        )
        emailSentText =
          requestSent
          ? "Receipt request sent to email '\(email)'."
          : "Could not send receipt request to email: '\(email)'."
      } catch {
        emailSentText = "Error requesting digital receipt: \(error.localizedDescription)"
      }
      showAlert = true
      isLoading = false
    }
  }
}

//#Preview {
//  TransactionOutcomeView()
//}
