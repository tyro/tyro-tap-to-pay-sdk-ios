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
        connectionProvider: DemoConnectionProvider(readerId: readerId),
        hapticFeedbackEnabled: true
      )
      contentViewModel = ContentViewModel(tapToPaySdk: tapToPaySdk)
      self.tapToPaySdk = tapToPaySdk
    } catch {
      fatalError(error.localizedDescription)
    }
  }

  var body: some View {
    VStack {
      HStack {
        Spacer()
        Button(action: {
          isSettingsPresented.toggle()
        }) {
          VStack {
            Image(systemName: "gear")
              .renderingMode(.template)
              .resizable()
              .frame(width: 25, height: 25)
          }
        }
        .buttonStyle(.plain)
        .fullScreenCover(isPresented: $isSettingsPresented) {
          TyroSettingsViewWrapper()
        }
      }
      .overlay(
        Image(.tyroLogo)
          .resizable()
          .scaledToFit()
          .aspectRatio(contentMode: .fit)
          .frame(width: 75, height: 75)
          .padding(), alignment: .center
      )
      .padding()
      ContentView(viewModel: contentViewModel)
    }
  }
}

struct TyroSettingsViewWrapper: View {
  @Environment(\.dismiss) var dismiss

  var body: some View {
    NavigationStack {
      TyroSettingsView()
        .toolbar(content: {
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

#if DEBUG
  #Preview {
    Home(readerId: "reader-id")
  }
#endif
