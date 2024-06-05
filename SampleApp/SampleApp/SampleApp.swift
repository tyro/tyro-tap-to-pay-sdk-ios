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
	var body: some Scene {
		WindowGroup {
			Home()
				.preferredColorScheme(.light)
				.navigationBarHidden(true)
		}
	}
}

struct Home : View {
	@Environment(\.scenePhase) private var scenePhase: ScenePhase
	@ObservedObject var tapToPaySdk: TyroTapToPay
	private var contentViewModel: ContentViewModel

	@State private var isSettingsPresented = false

	@State private var selectedIndex: Int = 0;

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
								.foregroundColor(.black)
						}.fullScreenCover(isPresented: $isSettingsPresented) {
							TyroSettingsView()
						}
					}.padding()
					ContentView(viewModel: contentViewModel)
				}.navigationTitle("")
			}.tabItem {
				Label("Home", systemImage: "house")
			}.tag(0)
			
			NavigationStack {
				SettingsView().navigationTitle("Tyro Settings")
			}.tabItem {
				Label("Admin", systemImage: "gear")
			}.tag(1)
		}
	}
}

struct TyroSettingsView: View {
	@Environment(\.dismiss) var dismiss
	var body: some View {
		NavigationStack {
			ZStack {
				SettingsView()
			}.toolbar(content: {
				Button {
					dismiss()
				} label: {
					Image(systemName: "xmark")
						.foregroundColor(.black)
				}
			})
		}
	}
}

extension TyroTapToPay: ObservableObject {

}
