//
//  TransactionOutcomeView.swift
//  SampleApp
//
//  Created by Sanjay Narayana on 1/5/2024.
//

import SwiftUI
import Foundation
import TyroTapToPaySDK

struct TransactionOutcomeView: View {
  private var transactionOutcome: TransactionOutcome
  
  init(_ transactionOutcome: TransactionOutcome) {
    self.transactionOutcome = transactionOutcome
  }
  
  var body: some View {
    VStack {
      Group {
        Image(systemName: "checkmark.circle.fill")
          .resizable()
          .frame(maxWidth: 100, maxHeight: 100)
        Text(transactionOutcome.statusMessage)
          .font(.title3)
          .multilineTextAlignment(.center)
        Text("Outcome: \(transactionOutcome.statusCode)")
          .font(.title2)
          .multilineTextAlignment(.center)
      }
      .foregroundStyle(transactionOutcome.statusCode == "APPROVED" ? .green : .red)
      
      ScrollView {
        Text(transactionOutcome.customerReceipt)
          .foregroundStyle(.gray)
          .monospaced()
          .padding()
      }
      .frame(maxHeight: .infinity, alignment: .bottom)
    }
  }
}

//#Preview {
//  TransactionOutcomeView()
//}
