//
//  ResetButton.swift
//  SampleApp
//
//  Created by Sanjay Narayana on 2/5/2024.
//

import Foundation
import SwiftUI

struct ResetButton: View {
  var onReset: () -> Void

  init(_ onReset: @escaping () -> Void) {
    self.onReset = onReset
  }

  var body: some View {
    Button {
      self.onReset()
    } label: {
      Text("Reset")
        .frame(maxWidth: .infinity, minHeight: 40)
        .font(.title2)
    }
    .buttonStyle(.borderedProminent)
    .padding()
  }
}
