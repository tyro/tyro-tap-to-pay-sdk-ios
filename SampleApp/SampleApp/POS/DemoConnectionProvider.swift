//
//  SandboxConnectionProvider.swift
//  SampleApp
//
//  Created by Christopher Grantham on 18/12/2023,
//  All rights reserved, Tyro Payments Limited.
//
import Foundation
import TyroTapToPaySDK

// Create an endpoint on your server to generate the connection secret
let DEMO_CONNECTION_SECRET_ENDPOINT_URL = "https://api.tyro.com/connect/tap-to-pay/demo/connections"

// Create the reader id and set it here
// Only one reader can be used on one device at any time otherwise transactions will fail
let DEMO_READER_ID = "f310e43b-a6c9-4c43-9535-ff68b2b9c4a1"

final class DemoConnectionProvider: ConnectionProvider {
  static let timeoutIntervalSeconds: TimeInterval = 10
  private let restClient = RestClient()

  func createConnection() async throws -> String {
    let payload = try JSONEncoder().encode(DemoConnectionRequest(readerId: DEMO_READER_ID))
    let response = try await restClient.post(
      requestUrl: DEMO_CONNECTION_SECRET_ENDPOINT_URL,
      payload: payload
    )
    return try JSONDecoder().decode(DemoConnectionResponse.self, from: response).connectionSecret
  }
}

struct DemoConnectionRequest: Codable {
  let readerId: String
}

struct DemoConnectionResponse: Codable {
  let connectionSecret: String
}
