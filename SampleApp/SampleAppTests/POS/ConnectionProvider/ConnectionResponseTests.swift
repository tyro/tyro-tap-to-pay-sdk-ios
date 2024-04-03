//
//  ConnectionResponseTests.swift
//  SampleAppTests
//
//  Created by Christopher Grantham on 8/3/2024.
//

import XCTest
@testable import SampleApp

final class ConnectionResponseTests: XCTestCase {
  private let dateFormatter: ISO8601DateFormatter = {
    let formatter = ISO8601DateFormatter()
    formatter.timeZone = .autoupdatingCurrent
    formatter.formatOptions = [
      .withDashSeparatorInDate,
      .withColonSeparatorInTime
    ]
    return formatter
  }()

  func test_can_decode_json_response_body_without_errors() throws {
    guard let data = json_response_body.data(using: .utf8) else {
      XCTFail()
      return
    }
    let decodedResponseBody = try JSONDecoder()
      .decode(ConnectionResponse.self, from: data)
    
    let date = dateFormatter.date(from: "2024-03-08T04:50:32.723Z")

    XCTAssertEqual(decodedResponseBody.id, 386)
    XCTAssertEqual(decodedResponseBody.connectionSecret, "$2a$10$r73IA4EmWUTaoCpL7u.ku.YKJn2Eec8L0KyebqSmYN.k4ugV41BPe")
    XCTAssertEqual(decodedResponseBody.createdDate, date)
    XCTAssertEqual(decodedResponseBody.readerId, UUID(uuidString: "f310e43b-a6c9-4c43-9535-ff68b2b9c4a1"))
    XCTAssertEqual(decodedResponseBody.readerName, "Sandbox demo reader iOS")
    XCTAssertEqual(decodedResponseBody.locationId, "tc-tap-to-pay-demo2-3000")
    XCTAssertEqual(decodedResponseBody.locationName, "Sandbox location 0b2c42bf-db7f-48ac-b23f-2a16bc4535fa")
  }

  let json_response_body = """
{
  "id":386,
  "connectionSecret": "$2a$10$r73IA4EmWUTaoCpL7u.ku.YKJn2Eec8L0KyebqSmYN.k4ugV41BPe",
  "createdDate": "2024-03-08T04:50:32.723Z",
  "readerId": "f310e43b-a6c9-4c43-9535-ff68b2b9c4a1",
  "readerName": "Sandbox demo reader iOS",
  "locationId": "tc-tap-to-pay-demo2-3000",
  "locationName": "Sandbox location 0b2c42bf-db7f-48ac-b23f-2a16bc4535fa"
}
"""
}
