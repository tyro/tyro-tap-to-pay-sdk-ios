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
  @State var readerId: String?

  var body: some Scene {
    WindowGroup {
      if readerId != nil {
        Home(readerId: readerId!)
          .navigationBarHidden(true)
      } else {
        EnterReaderIdView(onSubmitReaderId: { readerId in
          self.readerId = readerId
        })
      }
    }
  }
}

struct Home: View {
  @Environment(\.scenePhase) private var scenePhase: ScenePhase
  @ObservedObject var tapToPaySdk: TyroTapToPay
  private var contentViewModel: ContentViewModel

  @State private var isSettingsPresented = false
  @State private var selectedIndex: Int = 0

  init(readerId: String) {
    do {
      let tapToPaySdk = try TyroTapToPay(
        environment: .sandbox,
        connectionProvider: DemoConnectionProvider(readerId: readerId)
      )
      contentViewModel = ContentViewModel(tapToPaySdk: tapToPaySdk)
      self.tapToPaySdk = tapToPaySdk
    } catch {
      fatalError(error.localizedDescription)
    }
  }

  var body: some View {
    TabView(selection: $selectedIndex) {
      NavigationStack {
        VStack {
          HStack {
            Spacer(minLength: 0)
            Image(.tyroLogo)
              .resizable()
              .aspectRatio(contentMode: .fit)
              .frame(maxWidth: 100)
              .padding()
            Spacer(minLength: 0)
            Button(action: {
              isSettingsPresented.toggle()
            }) {
              Image(systemName: "gear")
                .renderingMode(.template)
                .resizable()
                .frame(width: 25, height: 25)
            }.fullScreenCover(isPresented: $isSettingsPresented) {
              TyroSettingsViewWrapper()
            }
          }.padding()
          ContentView(viewModel: contentViewModel)
        }.navigationTitle("")
      }.tabItem {
        Label("Home", systemImage: "house")
      }.tag(0)

      NavigationStack {
        TyroSettingsView().navigationTitle("Tyro Settings")
      }.tabItem {
        Label("Admin", systemImage: "gear")
      }.tag(1)
    }
  }
}

struct TyroSettingsViewWrapper: View {
  @Environment(\.dismiss) var dismiss
  var body: some View {
    NavigationStack {
      ZStack {
        TyroSettingsView()
      }.toolbar(content: {
        Button {
          dismiss()
        } label: {
          Image(systemName: "xmark")
        }
      })
    }
  }
}

extension TyroTapToPay: ObservableObject {

}
