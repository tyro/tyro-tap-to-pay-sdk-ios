//
//  PaymentFormView.swift
//  SampleApp
//
//  Created by Sanjay Narayana on 1/5/2024.
//

import SwiftUI

struct PaymentFormView: View {
  @State private var viewModel: ViewModel
  @FocusState private var isFocused: Bool
  var onSubmitPayment: (_ transactionType: TransactionType, _ amount: Decimal) -> Void

  init(onSubmitPayment: @escaping (_: TransactionType, _: Decimal) -> Void) {
    self.onSubmitPayment = onSubmitPayment
    self.viewModel = ViewModel(onSubmitPayment)
  }

  var body: some View {
    Form {
      Section(header: Text("Amount")) {
        VStack {
          TextField(
            "Amount",
            value: $viewModel.amount,
            format: .number,
            prompt: Text("")
          )
          .keyboardType(.decimalPad)
          .focused($isFocused)
          .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
              self.isFocused = true
            }
          }
        }
      }
    }
    Button {
      if viewModel.isValidAmount() {
        isFocused = false
        viewModel.isPresented = true
      }
    } label: {
      Text("Transact")
        .frame(maxWidth: .infinity, minHeight: 40)
        .font(.title2)
        .ignoresSafeArea()
    }
    .padding()
    .buttonStyle(.borderedProminent)
    .disabled(!viewModel.isValidAmount())
    .confirmationDialog("Actions", isPresented: $viewModel.isPresented) {
      Group {
        Button {
          viewModel.startPayment()
        } label: {
          Text("Payment")
            .font(.callout)
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity)
        }
        Button(role: .destructive) {
          viewModel.refundPayment()
        } label: {
          Text("Refund")
            .font(.callout)
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity)
        }
      }
    }
  }
}

extension PaymentFormView {
  @Observable
  class ViewModel: ObservableObject {
    var amount: Decimal? = nil
    var isPresented: Bool = false
    var onSubmitPayment: (_ transactionType: TransactionType, _ amount: Decimal) -> Void

    init(_ onSubmitPayment: @escaping (_: TransactionType, _: Decimal) -> Void) {
      self.onSubmitPayment = onSubmitPayment
    }

    func isValidAmount() -> Bool {
      let inputAmount = self.amount
      return (inputAmount != nil) && (inputAmount?.isNormal != false)
    }

    func startPayment() {
      guard let paymentAmount = amount, isValidAmount() else {
        return
      }
      onSubmitPayment(TransactionType.payment, paymentAmount)
    }

    func refundPayment() {
      guard let refundAmount = amount, isValidAmount() else {
        return
      }
      onSubmitPayment(TransactionType.refund, refundAmount)
    }
  }
}

#Preview {
  PaymentFormView(onSubmitPayment: {
    print($0, $1)
  })
}
