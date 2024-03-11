//
//  SandboxConnectionProvider.swift
//  SampleApp
//
//  Created by Christopher Grantham on 18/12/2023,
//  All rights reserved, Tyro Payments Limited.
//
import Foundation
import TyroTapToPaySDK

/// This is an implementation of the `ConnectionProvider` protocol to demonstrate connecting a reader id with the Tyro Sandbox environment.
/// You will need to implement `ConnectionProvider` in your own applications and call:
/// ```TyroTapToPaySDKTyroTapToPay.shared.initSDK(_:ConnectionProvider)```.
/// Tap to Pay on iPhone App.
/// > Note: You will need to implement your own `ConnectionProvider` to query your back-end for user lookup and respond with the relevant `ConnectionSecret`.
/// # See Also:
/// - [Tap to Pay connection endpoint](https://preview.redoc.ly/tyro-connect/pla-5831/pos/tap-to-pay/iphone/integrate-sdk/#tap-to-pay-connection-endpoint)
/// - [SandBox Testing](https://preview.redoc.ly/tyro-connect/pla-5831/pos/tap-to-pay/sandbox-testing/#sandbox-testing)
public class SandboxConnectionProvider : ConnectionProvider, ObservableObject {
  static let timeoutIntervalSeconds: TimeInterval = 10

  private let sandboxReaderId: String = "f310e43b-a6c9-4c43-9535-ff68b2b9c4a1"
  private let tyroRestClient: TyroRestClient

  @Published
  public var connectionResponse: ConnectionResponse? = nil

  /// This implementation uses a sample reader id and registers directly with the Tyro Sandbox environment.
  /// - Parameters:
  ///   - restClient: The ``TyroRestClient`` client instance configured for the Tyro-Tap-to-Pay environment you wish to use.
  init(restClient: TyroRestClient) {
    self.tyroRestClient = tyroRestClient
  }

  /// Create/Register the connection between this device reader and Tyro.
  /// - returns: the `ConnectionSecret` to use for authenticating and verifying connections with Tyro.
  /// - throws: an Error indicating either why the ConnectionProvider failed to connect to the POS server
  /// or why the `ConnectionSecret` could not be retrieved.
  public func createConnection() async throws -> String {
    let connectionResponse = try await tyroRestClient.createConnection(readerId: sandboxReaderId)
    MainActor.run {
      self.connectionResponse = connectionResponse
    }
    return responseBody.connectionSecret
  }
}
