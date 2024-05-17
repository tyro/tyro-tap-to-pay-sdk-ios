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
  @ObservedObject var tapToPaySdk: TyroTapToPay
  private var contentViewModel: ContentViewModel

  init() {
    do {
      let tapToPaySdk = try TyroTapToPay(
        environment: .sandbox,
        connectionProvider: DemoConnectionProvider()
      )
      contentViewModel = ContentViewModel(tapToPaySdk: tapToPaySdk)
      self.tapToPaySdk = tapToPaySdk
    } catch {
      fatalError(error.localizedDescription)
    }
  }

  var body: some Scene {
    WindowGroup {
      Image(.tyroLogo)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(maxWidth: 100)
        .padding()
      ContentView(viewModel: contentViewModel)
    }
  }
}

extension TyroTapToPay: ObservableObject {

}
