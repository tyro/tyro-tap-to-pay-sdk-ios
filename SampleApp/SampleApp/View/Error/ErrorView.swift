//
//  ErrorView.swift
//  SampleApp
//
//  Created by Sanjay Narayana on 1/5/2024.
//

import Foundation
import SwiftUI

struct ErrorView: View {
  private var errorMessage: String = ""
  
  init(errorMessage: String) {
    self.errorMessage = errorMessage
  }
  
  var body: some View {
    VStack {
      Image(systemName: "x.circle.fill")
        .resizable()
        .frame(maxWidth: 100, maxHeight: 100)
      Text(errorMessage)
        .font(.title2)
        .multilineTextAlignment(.center)
    }
    .foregroundStyle(.red)
  }
}
