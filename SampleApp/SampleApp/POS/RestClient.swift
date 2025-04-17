//
//  TyroRestClient.swift
//  SampleApp
//
//  Created by Christopher Grantham on 11/3/2024.
//

import Foundation

actor RestClient {
  private let urlSession: URLSession = {
    let configuration = URLSessionConfiguration.default
    configuration.timeoutIntervalForRequest = 10.0
    return URLSession(configuration: configuration)
  }()

  func post(requestUrl: String, payload: Data? = nil) async throws -> Data {
    guard let url = URL(string: requestUrl) else {
      throw URLError(.badURL)
    }
    var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    request.httpBody = payload

    let (data, _) = try await urlSession.data(for: request)
    return data
  }
}
