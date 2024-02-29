//
//  SampleApp.swift
//  SampleApp
//
//  Created by Ronaldo Gomes on 17/1/2024.
//

import SwiftUI
import TyroTapToPaySDK

class AppState: ObservableObject {
  @Published var tapToPayEnabled: Bool
  
  init(tapToPayEnabled: Bool) {
    self.tapToPayEnabled = tapToPayEnabled
  }
}

@main
struct SampleApp: App {
  @ObservedObject var appState = AppState(tapToPayEnabled: false)
  @Environment(\.scenePhase) var scenePhase
  
  init() {
    TyroTapToPay.shared.initSDK(connectionProvider: POSConnectionProvider())
  }
  
  var body: some Scene {
    WindowGroup {
      TabView {
        if self.appState.tapToPayEnabled {
          TransactionView().tabItem {
            Label("Transaction", systemImage: "square.and.pencil.circle.fill")
          }//.environmentObject(appState)
        } else {
          DisabledView().tabItem {
            Label("Transaction", systemImage: "square.and.pencil.circle.fill")
          }//.environmentObject(appState)
        }
        
        if self.appState.tapToPayEnabled {
          TransactionStatusView().tabItem {
            Label("Transaction Status", systemImage: "doc.text.fill")
          }//.environmentObject(appState)
        } else {
          DisabledView().tabItem {
            Label("Transaction", systemImage: "square.and.pencil.circle.fill")
          }//.environmentObject(appState)
        }
        
        EnableTapToPayView(appState: self.appState).tabItem {
          Label("Settings", systemImage: "gear")
        }//.environmentObject(appState)
      }
    }
    .onChange(of: scenePhase) { (oldValue, newValue) in
      switch newValue {
      case .active:
        print("Foreground or active")
//        TyroTapToPay.shared.onForeground()
      case .background, .inactive:
        print("Background or Inactive")
      @unknown default:
        print("Unknown scene value")
      }
    }
  }
}
