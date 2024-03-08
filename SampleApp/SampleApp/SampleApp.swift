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
  @Environment(\.scenePhase) private var scenePhase

  init() {
#if DEBUG
    NFX.sharedInstance().start()
#endif
  }

  var body: some Scene {
    WindowGroup {
      PaymentsView()
    }
    .onChange(of: scenePhase) { (_, newValue) in
      notificationCentre.post(name: Notification.Name(rawValue: "didChangeScenePhase"),
                              object: scenePhase)
    }
  }
}
