//
//  PaymentView.swift
//  SampleApp
//
//  Created by Sanjay Narayana on 30/4/2024.
//

import SwiftUI
import TyroTapToPaySDK

enum LoadingState {
  case loading(_ loadingMessage: String)
  case ready
  case error(_ errorMessage: String)
  case success(_ transactionOutcome: TransactionOutcome)
}

struct ContentView: View {
  @Environment(\.scenePhase) var scenePhase
  @State private var viewModel = ViewModel()
  
  var body: some View {
    VStack {
      Group {
        switch viewModel.state {
        case .error(let errorMessage):
          ErrorView(errorMessage: errorMessage)
        case .loading(let loadingMessage):
          ProgressView() {
            Text(loadingMessage)
              .font(.title)
              .frame(maxWidth: .infinity)
          }
          .foregroundStyle(.secondary)
        case .ready:
          VStack {
            Text("Ready")
              .font(.title)
          }
        case .success(let transactionOutcome):
          VStack {
            Image(systemName: "checkmark.circle.fill")
              .resizable()
              .frame(maxWidth: 100, maxHeight: 100)
            Text("Success: \(transactionOutcome.statusCode)")
              .font(.title)
              .multilineTextAlignment(.center)
            Text(transactionOutcome.statusMessage)
              .font(.title3)
              .multilineTextAlignment(.center)
          }
          .foregroundStyle(.green)
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      
      Button("Start") {
        Task {
          try await viewModel.startPayment()
        }
      }.padding()
      Button("Error") {
        viewModel.forceError()
      }.padding()
      Button("Reset") {
        viewModel.reset()
      }.padding()
    }
    .onChange(of: scenePhase) { (_, newPhase) in
      Task.detached {
        await self.viewModel.tapToPaySDK.didChange(scenePhase: newPhase)
      }
    }
  }
}

extension ContentView {
  @Observable
  class ViewModel: ObservableObject {
    private(set) var state: LoadingState
    var tapToPaySDK: TyroTapToPay
    private var amount: Decimal = 0.0
    
    init() {
      state = .loading("Initialising...")
      do {
        tapToPaySDK = try TyroTapToPay(
          environment: .sandbox,
          connectionProvider: DemoConnectionProvider()
        )
      } catch {
        state = .error(error.localizedDescription)
        fatalError(error.localizedDescription)
      }
      Task {
        await connectReader()
      }
    }
    
    private func connectReader() async {
      state = .loading("Connecting to reader...")
      Task {
        do {
          try await self.tapToPaySDK.connect()
          self.state = .ready
        } catch {
          self.state = .error(error.localizedDescription)
        }
      }
    }
    
    func startPayment() async throws {
      state = .loading("Processing payment...")
      let transactionDetail = TransactionDetail(
        amount: "66678",
        referenceNumber: UUID().uuidString,
        transactionID: UUID().uuidString,
        cardIsPresented: true,
        email: "snarayana@tyro.com",
        mobilePhoneNumber: "0433426702",
        posInformation: POSInformation(
          name: "Demo POS",
          vendor: "Demo",
          version: "1.0.0",
          siteReference: "Sydney"
        ),
        localeLanguage: Locale.current.language
      )
      do {
        let outcome = try await self.tapToPaySDK.startPayment(transactionDetail: transactionDetail)
        self.state = .success(outcome)
      } catch TapToPaySDKError.connectionProviderError {
        print("connectionProviderError")
        self.state = .error("connectionProviderError")
      } catch TapToPaySDKError.connectionProviderFailure {
        print("connectionProviderFailure")
        self.state = .error("connectionProviderFailure")
      } catch TapToPaySDKError.connectionProviderRetriesExhausted {
        print("connectionProviderRetriesExhausted")
        self.state = .error("connectionProviderRetriesExhausted")
      } catch TapToPaySDKError.connectionSecretNotInitialized {
        print("connectionSecretNotInitialized")
        self.state = .error("connectionSecretNotInitialized")
      } catch TapToPaySDKError.discoverReadersError {
        print("discoverReadersError")
        self.state = .error("discoverReadersError")
      } catch TapToPaySDKError.failedToVerifyConnection {
        print("failedToVerifyConnection")
        self.state = .error("failedToVerifyConnection")
      } catch TapToPaySDKError.fetchSdkDataError {
        print("fetchSdkDataError")
        self.state = .error("fetchSdkDataError")
      } catch TapToPaySDKError.fetchSessionCredentialsError {
        print("fetchSessionCredentialsError")
        self.state = .error("fetchSessionCredentialsError")
      } catch TapToPaySDKError.missingSessionCredentials {
        print("missingSessionCredentials")
        self.state = .error("missingSessionCredentials")
      } catch TapToPaySDKError.noProximityReaderFound {
        print("noProximityReaderFound")
        self.state = .error("noProximityReaderFound")
      } catch TapToPaySDKError.retryLimitExhausted {
        print("retryLimitExhausted")
        self.state = .error("retryLimitExhausted")
      } catch TapToPaySDKError.sdkUpgradeRequiredError {
        print("sdkUpgradeRequiredError")
        self.state = .error("sdkUpgradeRequiredError")
      } catch TapToPaySDKError.sessionInitialisationError {
        print("sessionInitialisationError")
        self.state = .error("sessionInitialisationError")
      } catch TapToPaySDKError.tapToPayInitialisationError {
        print("tapToPayInitialisationError")
        self.state = .error("tapToPayInitialisationError")
      } catch TapToPaySDKError.tapToPaySDKNotInitialised {
        print("tapToPaySDKNotInitialised")
        self.state = .error("tapToPaySDKNotInitialised")
      } catch TapToPaySDKError.transactionError(let errorMessage) {
        print("transactionError: \(errorMessage)")
        self.state = .error("transactionError: \(errorMessage)")
      } catch TapToPaySDKError.transactionStatusError {
        print("transactionStatusError")
        self.state = .error("transactionStatusError")
      } catch TapToPaySDKError.unableToConnectReader {
        print("unableToConnectReader")
        self.state = .error("unableToConnectReader")
      } catch TapToPaySDKError.unknownUiEvent {
        print("unknownUiEvent")
        self.state = .error("unknownUiEvent")
      } catch {
        print("Error")
        self.state = .error(error.localizedDescription)
      }
    }
    
    func forceError() {
      state = .error("Some error")
    }
    
    func reset() {
      state = .ready
    }
  }
}

//
//// MARK: Form
//struct MyPaymentForm: View {
//  @State private var viewModel = ViewModel()
//  
//  var body: some View {
//    Form {
//      Section(header: Text("Amount")) {
//        VStack {
//          TextField("Amount", value: $viewModel.amount, format: .number)
//            .keyboardType(.decimalPad)
//        }
//      }
//      Button("Submit") {
//        viewModel.submitPayment()
//      }
//    }
//  }
//}
//
//extension MyPaymentForm {
//  @Observable
//  class ViewModel {
//    var amount: Decimal = 0.0
//    
//    
//    func submitPayment() {
//      
//    }
//  }
//}

#Preview {
  ContentView()
}
