//
//  SampleApp.swift
//  SampleApp
//
//  Created by Christopher Grantham on 1/12/2023.
//

import SwiftUI
import TyroTapToPaySDK

@main
struct SampleApp: App {
	@Environment(\.scenePhase)
	private var scenePhase: ScenePhase
	@StateObject
	private var tapToPaySDK = TyroTapToPay.shared
	
	var body: some Scene {
		WindowGroup {
			ReaderDiscoveryView(adapter: ReaderDiscoveryAdapter(tyroTapToPaySDK: tapToPaySDK))
		}.onChange(of: scenePhase) { (newPhase, oldPhase) in
			switch newPhase {
			case .active:
				print("Foreground")
			case .background:
				print("Background")
			case .inactive:
				print("Inactive")
			@unknown default:
				return
			}
		}
	}
}
