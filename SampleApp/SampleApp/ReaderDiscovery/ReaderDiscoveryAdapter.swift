//
//  ReaderDiscoveryAdapter.swift
//  SampleApp
//
//  Created by Christopher Grantham on 13/2/2024.
//

import Foundation
import Combine

import TyroTapToPaySDK

class ReaderDiscoveryAdapter: ObservableObject {
	@Published var reader: ProximityReader?
	
	private let tyroTapToPaySDK: TyroTapToPay
	private var cancellables = Set<AnyCancellable>()
	
	init(tyroTapToPaySDK: TyroTapToPay) {
		self.tyroTapToPaySDK = tyroTapToPaySDK
		// Observe changes in discovered readers.
		tyroTapToPaySDK.readerDiscoveryEventPublisher.sink { [weak self] event in
			guard let self,
						case .didUpdateDiscoveredReaders(readers: let readers) = event else {
				return
			}
			reader = readers.first
		}.store(in: &cancellables)
	}
	
	func discoverReaders() async throws {
		try await tyroTapToPaySDK.discoverReaders()
	}
}
