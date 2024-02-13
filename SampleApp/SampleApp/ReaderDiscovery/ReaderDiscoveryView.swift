//
//  ContentView.swift
//  SampleApp
//
//  Created by Christopher Grantham on 1/12/2023.
//

import SwiftUI
import TyroTapToPaySDK

enum LoadingState {
	case ready
	case loading
	case error
}

struct ReaderDiscoveryView: View {
	private let adapter: ReaderDiscoveryAdapter
	@State
	private var loadingState: LoadingState = .ready
	
	init(adapter: ReaderDiscoveryAdapter) {
		self.adapter = adapter
	}
	
  var body: some View {
    VStack {
			Image(systemName: "globe")
				.imageScale(.large)
				.foregroundStyle(.tint)
			Text("Tap to Pay on iPhone")
			Button {
				Task {
					try await adapter.discoverReaders()
				}
			} label: {
				Text("Discover readers")
			}.disabled(loadingState == .loading)
      Spacer()
    }
    .padding()
  }
}
