//
//  ContentView.swift
//  tyro-tap-to-pay-ios-sample-app
//
//  Created by Ronaldo Gomes on 22/9/2023.
//

import SwiftUI
import Combine
import TyroTapToPaySDK

struct EnableTapToPayView: View {
  @StateObject var appState: AppState
  @State var presented: Bool = false

  var body: some View {
    VStack {
      Button {
        if self.appState.tapToPayEnabled {
          appState.tapToPayEnabled.toggle()
        } else {
          presented.toggle()
          Task {
            do {
              try await enableSDK()
            } catch {
              _ = Alert(title: Text("Error"),
                        message: Text("Unable to Connect Reader"),
                        dismissButton: .default(Text("Close")))
            }
          }
        }
      } label: {
        Text(self.appState.tapToPayEnabled ? "Disable Tap To Pay" : "Enable Tap To Pay")
          .presentationDetents([.medium])
          .presentationDragIndicator(.hidden)
          .buttonStyle(PlainButtonStyle())
          .padding(.horizontal, 30)
          .padding(.vertical, 30)
          .foregroundColor(.white)
          .background(.blue)
          .cornerRadius(8)
          .font(.system(size: 30))
      }
      .sheet(isPresented: $presented) {
        LoadingView(message: "Activating Tap to Pay", tintColor: .blue, scaleSize: 3.0)
      }
      .buttonStyle(PlainButtonStyle())
    }
  }
  
  private func enableSDK() async throws {
    var cancellables = Set<AnyCancellable>()
    TyroTapToPay.shared.readerDiscoveryEventPublisher.sink { event in
      guard case .didUpdateDiscoveredReaders(let readers) = event,
            let reader = readers.first else {
        return
      }
      TyroTapToPay.shared.initSDK(connectionProvider: POSConnectionProvider())
      Task {
        try await TyroTapToPay.shared.connectReader(reader)
      }
    }.store(in: &cancellables)
    Task {
        defer {
          presented.toggle()
        }
        try await TyroTapToPay.shared.discoverReaders()
        appState.tapToPayEnabled.toggle()
    }
  }
}

struct LoadingView: View {
  var message: String
  var tintColor: Color = .blue
  var scaleSize: CGFloat = 1.0
  
  init(message: String, tintColor: Color, scaleSize: CGFloat) {
    self.message = message
    self.tintColor = tintColor
    self.scaleSize = scaleSize
  }
  
  var body: some View {
    VStack {
      ProgressView()
        .scaleEffect(scaleSize, anchor: .center)
        .progressViewStyle(CircularProgressViewStyle(tint: tintColor))
        .padding(.bottom, 50)
      Text(message)
    }
  }
}
