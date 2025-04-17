//
//  ContentViewModel.swift
//  SampleApp
//
//  Created by Sanjay Narayana on 2/5/2024.
//

import Combine
import Foundation
import TyroTapToPaySDK

class ContentViewModel: ObservableObject {
  @Published var state: LoadingState = .loading("Loading...")
  @Published var transactionOutcome: TransactionOutcome?
  private var cancellables = Set<AnyCancellable>()

  var tapToPaySdk: TyroTapToPay
  var isConnected: Bool = false

  init(tapToPaySdk: TyroTapToPay) {
    self.tapToPaySdk = tapToPaySdk
  }

  func connect() async {
    tapToPaySdk
      .readerUpdatePublisher
      .sink { event in
        switch event {
        case .updateStarted:
          self.state = .loading("Reader update started")
        case .updateInProgress(let progress):
          self.state = .loading("Updating reader: \(progress)%")
        case .updateCompleted:
          self.state = .loading("Reader update complete")
        case .updateFailed(let error):
          self.state = .error("Reader update failed: \(error)")
        @unknown default:
          self.state = .loading("Unknown reader update event: \(event)")
        }
      }
      .store(in: &cancellables)
    do {
      self.state = .loading("Connecting to reader...")
      try await self.tapToPaySdk.connect()
      self.state = .ready
      self.isConnected = true
    } catch TapToPaySDKError.sessionInitialisationError(let errorMessage) {
      self.state = .error("sessionInitialisationError: \(errorMessage)")
    } catch TapToPaySDKError.retryLimitExhausted(let error) {
      self.state = .error("retryLimitExhausted (connectionSecret): \(error.localizedDescription)")
    } catch TapToPaySDKError.unableToConnectReader(let errorMessage) {
      self.state = .error("unableToConnectReader: \(errorMessage)")
    } catch TapToPaySDKError.discoverReadersError {
      self.state = .error("discoverReadersError")
    } catch TapToPaySDKError.sdkUpgradeRequiredError(let errorMessage) {
      self.state = .error("sdkUpgradeRequiredError: \(errorMessage)")
    } catch TapToPaySDKError.fetchSessionCredentialsError(let error) {
      self.state = .error("fetchSessionCredentialsError: \(error.localizedDescription)")
    } catch TapToPaySDKError.fetchSdkDataError(let errorMessage) {
      self.state = .error("fetchSdkDataError: \(errorMessage)")
    } catch TapToPaySDKError.noProximityReaderFound {
      self.state = .error(
        "noProximityReaderFound" + "\n\n"
          + "Please ensure you are using an iPhone with Tap to Pay on iPhone hardware capability (iPhone XS or above)"
      )
    } catch {
      self.state = .error(error.localizedDescription)
    }
  }

  func reset() {
    state = .ready
    transactionOutcome = nil
  }

  func startPayment(_ transactionType: TransactionType, _ amount: Decimal) async throws {
    self.state = .loading("Processing \(transactionType.rawValue.lowercased())...")
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
      if outcome.statusCode == "CANCELLED" {
        self.state = .error("Transaction cancelled.")
        return
      }
      self.state = .success(outcome)
      self.transactionOutcome = outcome
    } catch TapToPaySDKError.failedToVerifyConnection(let error) {
      self.state = .error("failedToVerifyConnection: \(error)")
    } catch TapToPaySDKError.transactionError(let errorMessage) {
      self.state = .error("transactionError: \(errorMessage)")
    } catch TapToPaySDKError.unableToConnectReader(let errorMessage) {
      self.state = .error("unableToConnectReader: \(errorMessage)")
    } catch TapToPaySDKError.invalidParameter(let errorMessage) {
      self.state = .error("invalidParameter: \(errorMessage)")
    } catch {
      self.state = .error(error.localizedDescription)
    }
  }

  private func formatAmount(_ amount: Decimal) -> String {
    let doubleValue = NSDecimalNumber(decimal: amount).doubleValue
    let roundedAmount = (doubleValue * 100).rounded() / 100
    let amountInCents = "\(Int(roundedAmount * 100))"
    return amountInCents
  }
}
