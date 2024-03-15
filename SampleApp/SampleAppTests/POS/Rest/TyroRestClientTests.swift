//
//  TyroRestClientTests.swift
//  SampleAppTests
//
//  Created by Christopher Grantham on 12/3/2024.
//

import XCTest
@testable import SampleApp

final class TyroRestClientTests: XCTestCase {
  let readerId = "f310e43b-a6c9-4c43-9535-ff68b2b9c4a1"
  let headers = ["Content-Type": "application/json"]
  let createConnectionUrl = "https://api.tyro.com/connect/tap-to-pay/demo/connections"

  func test_create_connection_success_for_readerId_in_sandbox() async throws {
    _ = try await self.createConnection(for: readerId)
  }

  private func createConnection(for readerId: String) async throws -> ConnectionResponse {
    guard let url = URL(string: createConnectionUrl) else {
      throw URLError(.badURL)
    }
    let requestBody = try JSONEncoder().encode(ConnectionRequest(readerId: readerId))
    print("Request: \t\(String(data: requestBody, encoding: .utf8)!)")
    var request = URLRequest(url: url,
                             cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                             timeoutInterval: 10.0)
    request.httpMethod = "POST"
    request.httpBody = try JSONEncoder().encode(ConnectionRequest(readerId: readerId))
    headers.forEach { request.addValue($0.value, forHTTPHeaderField: $0.key) }

    let (data, urlResponse) = try await URLSession.shared.data(for: request)
    print(String(data: data, encoding: .utf8)!)
    guard (urlResponse as? HTTPURLResponse)?.statusCode == 201 else {
      throw URLError(.badServerResponse)
    }
    return try JSONDecoder().decode(ConnectionResponse.self, from: data)
  }
}
