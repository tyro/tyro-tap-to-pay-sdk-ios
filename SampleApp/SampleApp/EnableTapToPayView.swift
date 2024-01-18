//
//  ContentView.swift
//  TyroByoIOS-SampleApp
//
//  Created by Ronaldo Gomes on 22/9/2023.
//

import SwiftUI
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
          enableSDK()
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
  
  func enableSDK() {
    TyroTapToPay.shared.readerDiscoveryDelegate = self
    Task {
//      try await TapToPaySDK.shared.discoverReader()
//      try await TyroTapToPay.shared.initSession()
      appState.tapToPayEnabled.toggle()
      self.presented.toggle()
    }
  }
}

extension EnableTapToPayView: TapToPaySDKReaderDiscoveryDelegate {
  func didUpdateDiscoveredReaders(readers: [Reader?]) {
    guard !readers.isEmpty else {
      _ = Alert(title: Text("Error"), message: Text("No readers found"), dismissButton: .default(Text("Close")))
      return
    }
    
    Task {
      do {
        try await TyroTapToPay.shared.connectReader(readers[0]!)
      } catch {
        _ = Alert(title: Text("Error"), message: Text("Unable to Connect Reader"), dismissButton: .default(Text("Close")))
      }
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
