//
//  ContentView.swift
//  SampleApp
//
//  Created by Christopher Grantham on 1/12/2023.
//

import SwiftUI
import TyroTapToPaySDK

struct ContentView: View {
  var body: some View {
    VStack {
      Image(systemName: "globe")
        .imageScale(.large)
        .foregroundStyle(.tint)
      Text("Hello, world!")
      Spacer()
      Button {
        TyroTapToPay.shared.discoverReaders()
      } label: {
        Text("Discover")
      }
      Spacer()
    }
    .padding()
  }
}

#Preview {
  ContentView()
}
