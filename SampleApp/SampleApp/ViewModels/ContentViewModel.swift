//
//  ContentViewModel.swift
//  SampleApp
//
//  Created by Sanjay Narayana on 2/5/2024.
//

import Foundation
import TyroTapToPaySDK

class ContentViewModel: ObservableObject {
  @Published var state: LoadingState = .loading("Loading...")
  @Published var transactionOutcome: TransactionOutcome?

  var tapToPaySdk: TyroTapToPay
  var isConnected: Bool = false

  init(tapToPaySdk: TyroTapToPay) {
    self.tapToPaySdk = tapToPaySdk
  }

  func showError(errorMessage: String) {
    state = .error(errorMessage)
  }

  func connect() async throws {
    do {
      DispatchQueue.main.async {
        self.state = .loading("Connecting to reader...")
      }
      try await self.tapToPaySdk.connect()
      DispatchQueue.main.async {
        self.state = .ready
        self.isConnected = true
      }
    } catch {
      DispatchQueue.main.async {
        self.state = .error(error.localizedDescription)
      }
    }
  }

  func reset() {
    DispatchQueue.main.async {
      self.state = .ready
      self.transactionOutcome = nil
    }
  }

  func startPayment(_ transactionType: TransactionType, _ amount: Decimal) async throws {
    DispatchQueue.main.async {
      self.state = .loading("Processing \(transactionType.rawValue.lowercased())...")
    }
    let transactionDetail = TransactionDetail(
      amount: formatAmount(amount),
      referenceNumber: UUID().uuidString,
      transactionID: UUID().uuidString,
      posInformation: POSInformation(
        name: "Demo POS",
        vendor: "Demo",
        version: "1.0.0",
        siteReference: "Sydney"
      )
    )
    do {
      let outcome =
        transactionType == .payment
        ? try await self.tapToPaySdk.startPayment(transactionDetail: transactionDetail)
        : try await self.tapToPaySdk.refundPayment(transactionDetail: transactionDetail)
      DispatchQueue.main.async {
        self.state = .success(outcome)
        self.transactionOutcome = outcome
      }
    } catch TapToPaySDKError.failedToVerifyConnection {
      DispatchQueue.main.async {
        self.state = .error("failedToVerifyConnection")
      }
    } catch TapToPaySDKError.transactionError(let errorMessage) {
      DispatchQueue.main.async {
        self.state = .error("transactionError: \(errorMessage)")
      }
    } catch TapToPaySDKError.unableToConnectReader {
      DispatchQueue.main.async {
        self.state = .error("unableToConnectReader")
      }
    } catch {
      DispatchQueue.main.async {
        self.state = .error(error.localizedDescription)
      }
    }
  }

  private func formatAmount(_ amount: Decimal) -> String {
    let doubleValue = NSDecimalNumber(decimal: amount).doubleValue
    let roundedAmount = (doubleValue * 100).rounded() / 100
    let amountInCents = "\(Int(roundedAmount * 100))"
    return amountInCents
  }
}
