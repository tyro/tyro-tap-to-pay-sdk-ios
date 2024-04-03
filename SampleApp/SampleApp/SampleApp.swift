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

  static let numberFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.maximumFractionDigits = 2
    formatter.decimalSeparator = ""
    formatter.groupingSeparator = ""
    return formatter
  }()

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
            await connect()
            withAnimation(.easeIn(duration: 1)) {
              opacity = 1.0
            }
          }
      case .ready:
        Image(.tyroLogo)
              .resizable()
              .aspectRatio(contentMode: .fit)
              .frame(maxWidth: 150)
        PaymentsView { (transactionType, amount) in
          Task.detached(priority: .userInitiated) {
            transactionOutcome = try await startTransaction(type: transactionType, amount: amount)
          }
        }
      }
    }.onChange(of: scenePhase) { (_, scenePhase) in
        // TODO: - notify SDK of change in foreground/background state.
      }
  }

  private func connect() async {
    Task.detached(priority: .userInitiated) {
      do {
        try await tapToPaySDK.connect()
        await MainActor.run {
          loadingState = .ready
        }
      } catch {
        await MainActor.run {
          loadingState = .failure(error)
        }
      }
    }
  }

  private func startTransaction(type transactionType: TransactionType,
                                amount: Decimal) async throws -> TransactionOutcome {
    guard let transactionDetail = transform(transactionType: transactionType, amount: amount) else {
      throw TapToPaySDKError.transactionError("Could not create TransactionDetail object.")
    }
    switch transactionType {
    case .payment:
      return try await tapToPaySDK.startPayment(transactionDetail: transactionDetail)
    case .refund:
      return try await tapToPaySDK.refundPayment(transactionDetail: transactionDetail)
    }
  }

  private func transform(transactionType: TransactionType, amount: Decimal) -> TransactionDetail? {
    guard let formattedAmount = Self.numberFormatter.string(from: NSDecimalNumber(decimal: amount)) else {
      return nil
    }
    let referenceNumber: String
    switch transactionType {
    case .payment:
      referenceNumber = UUID().uuidString
    case .refund:
      referenceNumber = ""
    }
    return TransactionDetail(amount: formattedAmount,
                             referenceNumber: referenceNumber,
                             transactionID: UUID().uuidString,
                             cardIsPresented: true,
                             email: "<email@domain.tld>",
                             mobilePhoneNumber: "<mobile-phone-number>",
                             posInformation: posInformation,
                             localeLanguage: Locale.current.language)
  }
}
