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
  private var notificationCentre = NotificationCenter.default
  @Environment(\.scenePhase) private var scenePhase: ScenePhase
  @State var loadingState: LoadingState = .inProgress("Initialising...")

  private let tyroEnvironment = TyroEnvironment.sandbox
  private let connectionProvider: ConnectionProvider
  private let tapToPaySDK: TyroTapToPay
  private let posInformation = POSInformation(name: "SampleApp POS",
                                              vendor: "Tyro",
                                              version: "0.2.0",
                                              siteReference: "Sydney")

  private var transactionOutcome: TransactionOutcome?

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
      case .ready:
        PaymentsView() { (transactionType, amount) in
          transactionOutcome = try await startTransaction(type: transactionType, amount: amount)
        }
      }
    }
  }

  private func startTransaction(type: TransactionType, 
                                amount: String) async throws -> TransactionOutcome {
    let transactionDetail = transform(amount)
    switch type {
    case .payment:
      return try await tapToPaySDK.startPayment(transactionDetail: transactionDetail)
    case .refund:
      return try await tapToPaySDK.refundPayment(transactionDetail: transactionDetail)
    }
  }

  private func transform(_ amount: String) -> TransactionDetail {
    TransactionDetail(amount: amount,
                      referenceNumber: "",
                      transactionID: UUID().uuidString,
                      cardIsPresented: true,
                      email: "<email>",
                      mobilePhoneNumber: "<mobilePhoneNumber>",
                      posInformation: posInformation,
                      localeLanguage: Locale.current.language)
  }
}
