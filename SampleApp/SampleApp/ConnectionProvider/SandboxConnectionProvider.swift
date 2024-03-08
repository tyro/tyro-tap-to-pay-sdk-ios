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
    let requestBody = ConnectionRequest(readerId: sandboxReaderId)
    let responseBody: ConnectionResponse = try await post(url: sandboxUrl,
                                                          requestPayload: requestBody)
    return responseBody.connectionSecret
  }

  private func post<T: Decodable>(url: URL, requestPayload: Encodable) async throws -> T {
    var request = URLRequest(url: url,
                             cachePolicy: .reloadIgnoringCacheData,
                             timeoutInterval: SandboxConnectionProvider.timeoutIntervalSeconds)
    
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    request.httpBody = try JSONEncoder().encode(requestPayload)

    let (data, response) = try await URLSession.shared.data(for: request)
    // HTTP 201 indicates that the ConnectionSecret was created successfully.
    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
      throw TapToPaySDKError.connectionProviderFailure
    }
    return try JSONDecoder().decode(T.self, from: data)
  }
}
