//
//  SandboxConnectionProvider.swift
//  SampleApp
//
//  Created by Christopher Grantham on 18/12/2023,
//  All rights reserved, Tyro Payments Limited.
//
import Foundation
import TyroTapToPaySDK

/// This is an implementation of the ConnectionProvider protocol for demonstration purposes and is configured to work with the SandBox environment.
/// You will need to implement `ConnectionProvider` in your own applications and call ``TyroTapToPaySDK/TyroTapToPaySDKinit``.
/// Tap to Pay on iPhone App.
/// For more info, see: - ()[]
public class SandboxConnectionProvider : ConnectionProvider {
  static let timeoutIntervalSeconds: TimeInterval = 10
  
  private let sandboxReaderId: String = "f310e43b-a6c9-4c43-9535-ff68b2b9c4a1"
  private let sandboxConnectionUrl: String = "https://api.tyro.com/connect/tap-to-pay/demo/connections"

  ///
  /// - returns: a ConnectionSecret used to authenticate and verify connections with Tyro/
  /// - throws: an Error indicating either why the ConnectionProvider failed to connect to the POS server
  /// or why the connection secret could not be retrieved.
  public func createConnection() async throws -> String {
    guard let sandboxUrl = URL(string: sandboxConnectionUrl) else {
      throw TyroTapToPaySDK.TapToPaySDKError.connectionProviderFailure
    }
    let response = try await post(url: sandboxUrl, requestPayload: ConnectionRequest(readerId: sandboxReaderId))
    let connectionResponse = try JSONDecoder().decode(ConnectionResponse.self, from: response)
    return connectionResponse.connectionSecret
  }
/**
 {"id":316,
  "connectionSecret":"$2a$10$3M9j6OpIqvVbIJ2giFjEg.nQK5dFGNwGhHxjZXTWwC5zezOQcFsZS",
  "createdDate":"2024-03-06T05:28:49.567Z",
  "readerId":"bf25e679-ee58-4574-9d1f-4a0ec1cb99bb",
  "readerName":"sandbox demo reader android test 1",
  "locationId":"tc-taptopaydemo3-4940",
  "locationName":"Sandbox Location 1fde2e05-becd-4505-9c5e-68b21f874be0"}%
  return "$2a$10$3M9j6OpIqvVbIJ2giFjEg.nQK5dFGNwGhHxjZXTWwC5zezOQcFsZS"
 */
  private func post(url: URL, requestPayload: Encodable) async throws -> Data {
    var request = URLRequest(url: url,
                             cachePolicy: .reloadIgnoringCacheData,
                             timeoutInterval: SandboxConnectionProvider.timeoutIntervalSeconds)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    request.httpBody = try JSONEncoder().encode(requestPayload)

    let (data, response) = try await URLSession.shared.data(for: request)
    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
      throw TapToPaySDKError.connectionProviderFailure
    }
    return data
  }
}
