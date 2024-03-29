//
//  ConnectionResponse.swift
//  SampleApp
//
//  Created by Christopher Grantham on 8/3/2024.
//

import Foundation

public struct ConnectionResponse: Decodable {
  public let id: Int
  public let connectionSecret: String
  public let createdDate: Date
  public let readerId: UUID
  public let readerName: String
  public let locationId: String
  public let locationName: String

  enum CodingKeys: CodingKey {
    case id
    case connectionSecret
    case createdDate
    case readerId
    case readerName
    case locationId
    case locationName
  }

  private let dateFormatter: ISO8601DateFormatter = {
    let formatter = ISO8601DateFormatter()
    formatter.timeZone = .autoupdatingCurrent
    formatter.formatOptions = [
      .withDashSeparatorInDate,
      .withColonSeparatorInTime
    ]
    return formatter
  }()

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.id = try container.decode(Int.self, forKey: .id)
    self.connectionSecret = try container.decode(String.self, forKey: .connectionSecret)
    
    let dateString = try container.decode(String.self, forKey: .createdDate)
    if let dateValue = dateFormatter.date(from: dateString) {
      self.createdDate = dateValue
    } else {
      throw DecodingError.dataCorruptedError(forKey: .createdDate,
                                             in: container,
                                             debugDescription: "Date must conform to ISO8601 format.")
    }

    self.readerId = try container.decode(UUID.self, forKey: .readerId)
    self.readerName = try container.decode(String.self, forKey: .readerName)
    self.locationId = try container.decode(String.self, forKey: .locationId)
    self.locationName = try container.decode(String.self, forKey: .locationName)
  }
}
