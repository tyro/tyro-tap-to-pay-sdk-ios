//
//  POSConnectionProvider.swift
//  SampleApp
//
//  Created by Ronaldo Gomes on 22/9/2023.
//

import TyroTapToPaySDK

public class POSConnectionProvider : TapToPayConnectionProvider {
  public func createConnection() async throws -> String {
    // A call to the POS servers should happen here
    return "Should return the connection string"
  }
}
