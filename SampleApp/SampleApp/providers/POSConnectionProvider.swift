//
//  POSConnectionProvider.swift
//  TyroByoIOS-SampleApp
//
//  Created by Ronaldo Gomes on 22/9/2023.
//

import TyroTapToPaySDK

public class POSConnectionProvider : TapToPayConnectionProvider {
  public func createConnection() async throws -> String {
    // A call to the POS servers should happen here
    return "User the returned connection secret"
  }
}
