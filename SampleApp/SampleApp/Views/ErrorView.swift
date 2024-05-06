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

  @State private var show = true

  init(errorMessage: String) {
    self.errorMessage = errorMessage
  }

  var body: some View {
    VStack {
      Image(systemName: "x.circle.fill")
        .resizable()
        .frame(maxWidth: 75, maxHeight: 75)
        .padding()
      Text(errorMessage)
        .font(.title2)
        .multilineTextAlignment(.center)
    }
    .foregroundStyle(.red)
  }
}

#Preview {
  ErrorView(errorMessage: "Something")
}
