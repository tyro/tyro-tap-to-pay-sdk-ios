//
//  LoadingState.swift
//  SampleApp
//
//  Created by Christopher Grantham on 20/3/2024.
//

import Foundation

enum LoadingState: Equatable {
  static func == (lhs: LoadingState, rhs: LoadingState) -> Bool {
    switch (lhs, rhs) {
    case (.inProgress(let lhsTitle), .inProgress(let rhsTitle)):
      return lhsTitle == rhsTitle
    case (.ready, .ready):
      return true
    case (.failure(let lhsError), .failure(let rhsError)):
      return lhsError.localizedDescription == rhsError.localizedDescription
    default:
      return false
    }
  }

  case inProgress(String)
  case ready
  case failure(Error)
}
