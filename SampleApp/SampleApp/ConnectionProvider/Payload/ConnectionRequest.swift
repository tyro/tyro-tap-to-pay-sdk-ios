//
//  ConnectionRequest.swift
//  SampleApp
//
//  Created by Christopher Grantham on 8/2/2024.
//

import Foundation

/// You can test request and response conditions with this command
///curl https://api.tyro.com/connect/tap-to-pay/demo/connections \
/// -H "Accept: application/json" \
/// -H "Content-Type: application/json" \
/// -X POST \
/// -d "{\"readerId\":\"insert_your_reader_id_here\"}"
///
struct ConnectionRequest: Encodable {
  let readerId: String
}


