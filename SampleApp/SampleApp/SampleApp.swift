//
//  SampleApp.swift
//  SampleApp
//
//  Created by Christopher Grantham on 26/2/2024.
//

import SwiftUI
import TyroTapToPaySDK

@main
struct SampleApp: App {
  @Environment(\.scenePhase) private var scenePhase: ScenePhase
  @State var loadingState: LoadingState = .inProgress("Initialising...")
  @State var transactionOutcome: TransactionOutcome?
  @State var opacity: Float = .zero

  private let tyroEnvironment = TyroEnvironment.sandbox
  private let connectionProvider: ConnectionProvider
  private let tapToPaySDK: TyroTapToPay
  private let posInformation = POSInformation(name: "SampleApp POS",
                                              vendor: "Tyro",
                                              version: "0.3.0",
                                              siteReference: "Sydney")

  init() {
    let restClient = TyroRestClient(environment: tyroEnvironment)
    connectionProvider = SandboxConnectionProvider(restClient: restClient)
    do {
      tapToPaySDK = try TyroTapToPay(environment: .sandbox, connectionProvider: connectionProvider)
    }
    catch {
      fatalError(error.localizedDescription)
    }
  }

  var body: some Scene {
    WindowGroup {
      switch loadingState {
      case .inProgress, .failure:
        LoadingView(loadingState: $loadingState)
          .task {
            Task.detached(priority: .userInitiated) {
              do {
                try await tapToPaySDK.connect()
              } catch {
                loadingState = .failure(error)
              }
            }
            withAnimation(.easeIn(duration: 1)) {
              opacity = 1.0
            }
          }
      case .ready:
        PaymentsView { (transactionType, amountText) in
          transactionOutcome = try await startTransaction(type: transactionType, amountText: amountText)
        }
      }
    }.onChange(of: scenePhase) { (_, scenePhase) in
        // TODO: - notify SDK of change in foreground/background state.
      }
  }

  private func startTransaction(type transactionType: TransactionType,
                                amountText: String) async throws -> TransactionOutcome {
    let transactionDetail = transform(transactionType: transactionType, amountText: amountText)
    switch transactionType {
    case .payment:
      return try await tapToPaySDK.startPayment(transactionDetail: transactionDetail)
    case .refund:
      return try await tapToPaySDK.refundPayment(transactionDetail: transactionDetail)
    }
  }

  private func transform(transactionType: TransactionType, amountText: String) -> TransactionDetail {
    let referenceNumber: String
    switch transactionType {
    case .payment:
      referenceNumber = UUID().uuidString
    case .refund:
      referenceNumber = ""
    }
    return TransactionDetail(amount: amountText,
                             referenceNumber: referenceNumber,
                             transactionID: UUID().uuidString,
                             cardIsPresented: true,
                             email: "<email@domain.tld>",
                             mobilePhoneNumber: "<mobile-phone-number>",
                             posInformation: posInformation,
                             localeLanguage: Locale.current.language)
  }
}
