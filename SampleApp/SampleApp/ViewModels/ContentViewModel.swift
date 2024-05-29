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

    Task(priority: .userInitiated) { [weak self] in
      await self?.connect()
    }
  }

  func connect() async {
    do {
      await MainActor.run {
        self.state = .loading("Connecting to reader...")
      }
      try await self.tapToPaySdk.connect()
      await MainActor.run {
        self.state = .ready
        self.isConnected = true
      }
    } catch TapToPaySDKError.sessionInitialisationError(let errorMessage) {
      await MainActor.run {
        self.state = .error("sessionInitialisationError: \(errorMessage)")
      }
    } catch TapToPaySDKError.retryLimitExhausted(let error) {
      await MainActor.run {
        self.state = .error("retryLimitExhausted (connectionSecret): \(error.localizedDescription)")
      }
    } catch TapToPaySDKError.unableToConnectReader(let errorMessage) {
      await MainActor.run {
        self.state = .error("unableToConnectReader: \(errorMessage)")
      }
    } catch TapToPaySDKError.discoverReadersError {
      await MainActor.run {
        self.state = .error("discoverReadersError")
      }
    } catch TapToPaySDKError.sdkUpgradeRequiredError(let errorMessage) {
      await MainActor.run {
        self.state = .error("sdkUpgradeRequiredError: \(errorMessage)")
      }
    } catch TapToPaySDKError.fetchSessionCredentialsError(let error) {
      await MainActor.run {
        self.state = .error("fetchSessionCredentialsError: \(error.localizedDescription)")
      }
    } catch TapToPaySDKError.fetchSdkDataError(let errorMessage) {
      await MainActor.run {
        self.state = .error("fetchSdkDataError: \(errorMessage)")
      }
    } catch TapToPaySDKError.noProximityReaderFound {
      await MainActor.run {
        self.state = .error("noProximityReaderFound" +
                            "\n\n" +
                            "Please ensure you are using an iPhone with Tap to Pay on iPhone hardware capability (iPhone XS or above)"
        )
      }
    } catch {
      await MainActor.run {
        self.state = .error(error.localizedDescription)
      }
    }
  }

  func reset() {
      state = .ready
      transactionOutcome = nil
  }

  func startPayment(_ transactionType: TransactionType, _ amount: Decimal) async throws {
    await MainActor.run {
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
      await MainActor.run {
        self.state = .success(outcome)
        self.transactionOutcome = outcome
      }
    } catch TapToPaySDKError.failedToVerifyConnection {
      await MainActor.run {
        self.state = .error("failedToVerifyConnection")
      }
    } catch TapToPaySDKError.transactionError(let errorMessage) {
      await MainActor.run {
        self.state = .error("transactionError: \(errorMessage)")
      }
    } catch TapToPaySDKError.unableToConnectReader(let errorMessage) {
      await MainActor.run {
        self.state = .error("unableToConnectReader: \(errorMessage)")
      }
    } catch TapToPaySDKError.invalidParameter(let errorMessage) {
      await MainActor.run {
        self.state = .error("invalidParameter: \(errorMessage)")
      }
    } catch {
      await MainActor.run {
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
