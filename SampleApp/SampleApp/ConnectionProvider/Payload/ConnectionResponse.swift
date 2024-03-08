//
//  ConnectionResponse.swift
//  SampleApp
//
//  Created by Christopher Grantham on 8/3/2024.
//

import Foundation

struct ConnectionResponse: Decodable {
  let id: Int
  let connectionSecret: String
  let createdDate: Date
  let readerId: UUID
  let readerName: String
  let locationId: String
  let locationName: String
}
