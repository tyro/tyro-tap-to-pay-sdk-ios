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
  @StateObject private var viewModel: ContentViewModel
  @State private var firstLoad = true
  
  init(viewModel: ContentViewModel) {
    _viewModel = StateObject(wrappedValue: viewModel)
  }

  var body: some View {
    VStack {
      Group {
        switch viewModel.state {
        case .error(let errorMessage):
          Group {
            ErrorView(errorMessage: errorMessage)
          }.frame(maxHeight: .infinity, alignment: .center)
          Group {
            if viewModel.isConnected {
              ResetButton({
                viewModel.reset()
              })
            } else {
              CloseButton()
            }
          }
          .frame(alignment: .bottom)

        case .loading(let loadingMessage):
          ProgressView {
            Text(loadingMessage)
              .font(.title)
              .frame(maxWidth: .infinity)
          }
          .foregroundStyle(.secondary)

        case .ready:
          PaymentFormView(onSubmitPayment: { (transactionType, amount) in
            Task.detached(priority: .userInitiated) {
              try await viewModel.startPayment(transactionType, amount)
            }
          })

        case .success(let transactionOutcome):
          TransactionOutcomeView(transactionOutcome, viewModel.tapToPaySdk)
          ResetButton({
            viewModel.reset()
          }).frame(alignment: .bottom)
        }
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .onChange(of: scenePhase) { (_, newValue) in
      Task.detached {
        await self.viewModel.tapToPaySdk.didChange(scenePhase: newValue)
      }
    }
    .task {
      guard firstLoad else {
        return
      }
      firstLoad = false
      do {
        try await viewModel.connect()
      } catch {
        viewModel.showError(errorMessage: error.localizedDescription)
      }
    }
  }
}
