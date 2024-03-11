//
//  TyroRestClient.swift
//  SampleApp
//
//  Created by Christopher Grantham on 11/3/2024.
//

import Foundation

/// This is a sample implementation for the purpose of demonstrating the creation of a Tap to pay Connection with Tyro.
/// > Tip: Tyro production APIs require an `Authorization`  with bearer token (`JWT`) header.
/// ---
/// > Note: This functionality would normally be implemented in the POS Server, this iOS sample is provided for demonstration purposes only.
/// [Authentication for POS Instance Connections](https://preview.redoc.ly/tyro-connect/pla-5831/pos/authentication/device-code/#authentication-for-pos-instance-connections).
/// ---
/// # See also:
/// - [Authentication for POS Instance Connections](https://preview.redoc.ly/tyro-connect/pla-5831/pos/authentication/device-code/#authentication-for-pos-instance-connections).
/// - [High Level Overview of Tap to Pay Flow](https://preview.redoc.ly/tyro-connect/pla-5831/pos/tap-to-pay/iphone/integrate-sdk/#high-level-overview-of-tap-to-pay-flow)
class TyroRestClient {

  enum EnvironmentUrl: String {
    case prod = "https://api.tyro.com/connect/tap-to-pay/create-connection"
    case sandBox = "https://api.tyro.com/connect/tap-to-pay/demo/create-connection"
  }

  private weak var urlSession: URLSession?
  private let environmentUrl: EnvironmentUrl

  init(environment: TyroRestClient.EnvironmentUrl, urlSession: URLSession = .shared) {
    self.environmentUrl = environmentUrl
    self.urlSession = urlSession
  }

  ///
  /// - Parameter readerId: The ID of the reader to be used to establish the connection.
  /// - Returns: The response payload.
  /// - Throws: An error if something goes wrong.
  func createConnection(readerId: String) async throws -> ConnectionResponse {
    guard let tyroUrl = URL(string: environmentUrl) else {
      throw TyroTapToPaySDK.TapToPaySDKError.connectionProviderFailure
    }
    return try await post(url: tyroUrl, requestPayload: ConnectionRequest(readerId: readerId))
  }

  private func post<T: Decodable>(url: URL, requestPayload: Encodable) async throws -> T {
    var request = URLRequest(url: url,
                             cachePolicy: .reloadIgnoringCacheData,
                             timeoutInterval: SandboxConnectionProvider.timeoutIntervalSeconds)

    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    request.httpBody = try JSONEncoder().encode(requestPayload)

    let (data, urlResponse) = try await urlSession.data(for: request)
    guard let httpUrlResponse = urlResponse as? HTTPURLResponse,
          let httpStatusCode = ClientStatus(rawValue: httpUrlResponse.statusCode) else {
      throw ClientStatus.ClientError.unhandledError
    }
    
  }
}

enum indirect ClientStatus: Int, Error {
  case created = 201
//  case badRequest = 400
//  case forbidden = 403
//  case notFound = 404
//  case requestTimedOut = 408
//  case internalServerError = 500

  enum ClientError: Int, Error {
    case requestNotValid = 400
    case permissionDenied = 403
    case readerIdDoesNotExist = 404
    case requestTimedOut = 408
    case unhandledError(Int)

    init(statusCode: ClientStatusCode) {
      guard let value = ClientError(rawValue: statusCode.rawValue) else {
        self = .unhandledError(statusCode.rawValue)
      }
    }
  }

  func result<T: Decodable>(data: Data) throws -> T {
    switch self {
    case .created:
      return try JSONDecoder().decode(T.self, from: data)
    case .badRequest, .forbidden, .notFound, .requestTimedOut:
      throw CreateConnectionError(statusCode: rawValue)
    }
  }
}

//enum ClientError: Int, Error {
//  case requestNotValid = 400
//  case permissionDenied = 403
//  case readerIdDoesNotExist = 404
//  case requestTimedOut = 408
//  case unhandledError(Int)
//
//  init(statusCode: ClientStatusCode) {
//    guard let value = ClientError(rawValue: statusCode.rawValue) else {
//      self = .unhandledError(statusCode.rawValue)
//    }
//  }
//}
