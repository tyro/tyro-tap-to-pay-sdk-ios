//
//  TyroRestClient.swift
//  SampleApp
//
//  Created by Christopher Grantham on 11/3/2024.
//

import Foundation
import TyroTapToPaySDK

/// This is a sample implementation for the purpose of demonstrating the creation of a Tap to pay Connection with Tyro.
/// > Tip: Tyro production APIs require an `Authorization`  bearer token (`JWT`) header while the Tyro sandbox does not.
/// ---
/// > Note: This functionality would normally be implemented in the POS Server, this iOS sample is provided for demonstration purposes only.
/// ---
/// # See also:
/// - [Authentication for POS Instance Connections](https://preview.redoc.ly/tyro-connect/pla-5831/pos/authentication/device-code/#authentication-for-pos-instance-connections).
/// - [High Level Overview of Tap to Pay Flow](https://preview.redoc.ly/tyro-connect/pla-5831/pos/tap-to-pay/iphone/integrate-sdk/#high-level-overview-of-tap-to-pay-flow)
class TyroRestClient {
  let environment: TyroEnvironment

  let baseURL = "https://api.tyro.com/connect/tap-to-pay"

  var connectionURL: String {
    switch environment {
    case .sandbox:
      return "\(baseURL)/demo/connections"
    default:
      return "\(baseURL)/connections"
    }
  }

  init(environment: TyroEnvironment) {
    self.environment = environment
  }

  ///
  /// - Parameter readerId: The ID of the reader to be used to establish the connection.
  /// - Returns: The ``ConnectionResponse`` payload.
  /// - Throws: If the request fails or has invalid data.
  func createConnection(for readerId: String) async throws -> ConnectionResponse {
    guard let url = URL(string: connectionURL) else {
      throw URLError(.badURL)
    }
    var request = URLRequest(url: url,
                             cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                             timeoutInterval: 10.0)
    request.httpMethod = "POST"
    request.httpBody = try JSONEncoder().encode(ConnectionRequest(readerId: readerId))
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")

    let (data, urlResponse) = try await URLSession.shared.data(for: request)
    guard let httpURLResponse = urlResponse as? HTTPURLResponse,
          let httpResponseStatusCode = HTTPResponseStatusCode(rawValue: httpURLResponse.statusCode) else {
      throw URLError(.badServerResponse)
    }
    guard httpResponseStatusCode == .created else {
      throw ClientError(statusCode: httpResponseStatusCode)
    }
    return try JSONDecoder().decode(ConnectionResponse.self, from: data)
  }
}

enum HTTPResponseStatusCode: Int {
  case created = 201
  case badRequest = 400
  case forbidden = 403
  case notFound = 404
  case requestTimedOut = 408
  case internalServerError = 500
}

enum ClientError: Error {
  case requestNotValid
  case permissionDenied
  case readerIdDoesNotExist
  case unhandledError(Int)

  init(statusCode: HTTPResponseStatusCode) {
    switch statusCode {
    case .badRequest:
      self = .requestNotValid
    case .forbidden:
      self = .permissionDenied
    case .notFound:
      self = .readerIdDoesNotExist
    default:
      self = .unhandledError(statusCode.rawValue)
    }
  }
}
