//
//  Transaction.swift
//  SampleApp
//
//  Created by Christopher Grantham on 20/3/2024.
//

import Foundation
import SwiftUI
import TyroTapToPaySDK

enum TransactionType: String, Hashable, CaseIterable {
  case payment = "Payment"
  case refund = "Refund"

  var foregroundColor: Color {
    switch self {
    case .payment:
      return .accentColor
    case .refund:
      return .red
    }
  }
}

enum TransactionProcessingState {
  case ready
  case inProgress(TransactionType, String)
  case failed(Error)
}
