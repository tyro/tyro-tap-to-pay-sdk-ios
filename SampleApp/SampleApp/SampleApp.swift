//
//  SampleApp.swift
//  SampleApp
//
//  Created by Christopher Grantham on 26/2/2024.
//

import SwiftUI
import TyroTapToPaySDK
import netfox

@main
struct SampleApp: App {
  private var notificationCentre = NotificationCenter.default
  @Environment(\.scenePhase) private var scenePhase: ScenePhase

  private let tyroEnvironment = TyroEnvironment.sandbox
  private let connectionProvider: ConnectionProvider
  private let tapToPaySDK: TyroTapToPay

  init() {
#if DEBUG
    NFX.sharedInstance().start()
#endif
    let restClient = TyroRestClient(environment: tyroEnvironment)
    self.connectionProvider = SandboxConnectionProvider(restClient: restClient)
    self.tapToPaySDK = TyroTapToPay(environment: tyroEnvironment,
                                    connectionProvider: connectionProvider)
  }

  var body: some Scene {
    WindowGroup {
      PaymentsView(viewModel: PaymentsViewModel(tapToPaySDK: tapToPaySDK))
    }
    .onChange(of: scenePhase) { (_, newValue) in
      notificationCentre.post(name: Notification.Name(rawValue: "didChangeScenePhase"),
                              object: scenePhase)
    }
  }
}
