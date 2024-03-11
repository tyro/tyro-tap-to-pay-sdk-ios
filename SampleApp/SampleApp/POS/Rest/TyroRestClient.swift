//
//  TyroRestClient.swift
//  SampleApp
//
//  Created by Christopher Grantham on 11/3/2024.
//

import Foundation
import TyroTapToPaySDK

extension TyroEnvironment {
  var createConnectionUrl: String {
    switch self {
    case .sandbox:
      return "https://api.tyro.com/connect/tap-to-pay/demo/create-connection"
    default:
      return "https://api.tyro.com/connect/tap-to-pay/create-connection"
    }
  }
}

/// This is a sample implementation for the purpose of demonstrating the creation of a Tap to pay Connection with Tyro.
/// > Tip: Tyro production APIs require an `Authorization`  bearer token (`JWT`) header.
/// ---
/// > Note: This functionality would normally be implemented in the POS Server, this iOS sample is provided for demonstration purposes only.
/// ---
/// # See also:
/// - [Authentication for POS Instance Connections](https://preview.redoc.ly/tyro-connect/pla-5831/pos/authentication/device-code/#authentication-for-pos-instance-connections).
/// - [High Level Overview of Tap to Pay Flow](https://preview.redoc.ly/tyro-connect/pla-5831/pos/tap-to-pay/iphone/integrate-sdk/#high-level-overview-of-tap-to-pay-flow)
class TyroRestClient {
  private weak var urlSession: URLSession?
  private let environment: TyroEnvironment

  init(environment: TyroEnvironment, urlSession: URLSession = .shared) {
    self.environment = environment
    self.urlSession = urlSession
  }

  ///
  /// - Parameter readerId: The ID of the reader to be used to establish the connection.
  /// - Returns: The ``ConnectionResponse`` payload.
  /// - Throws: If the request fails or has invalid data.
  func createConnection(readerId: String) async throws -> ConnectionResponse {
    guard let tyroUrl = URL(string: environment.createConnectionUrl) else {
      throw URLError(.badURL)
    }
    return try await post(url: tyroUrl, requestPayload: ConnectionRequest(readerId: readerId))
  }

  private func post<T: Decodable>(url: URL, requestPayload: Encodable) async throws -> T {
    guard let urlSession else {
      throw URLError(.cancelled)
    }
    var request = URLRequest(url: url,
                             cachePolicy: .reloadIgnoringCacheData,
                             timeoutInterval: SandboxConnectionProvider.timeoutIntervalSeconds)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    request.httpBody = try JSONEncoder().encode(requestPayload)

    let (data, urlResponse) = try await urlSession.data(for: request)
    guard let httpUrlResponse = urlResponse as? HTTPURLResponse,
          let httpStatusCode = HttpClientStatusCode(rawValue: httpUrlResponse.statusCode) else {
      throw URLError(.badServerResponse)
    }
    switch httpStatusCode {
    case .created:
      return try JSONDecoder().decode(T.self, from: data)
    default:
      throw ClientError(statusCode: httpStatusCode)
    }
  }
}

enum HttpClientStatusCode: Int {
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

  init(statusCode: HttpClientStatusCode) {
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
