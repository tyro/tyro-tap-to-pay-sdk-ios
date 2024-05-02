//
//  CloseButton.swift
//  SampleApp
//
//  Created by Sanjay Narayana on 2/5/2024.
//

import SwiftUI
import Foundation

struct CloseButton: View {
  var body: some View {
    Button {
      exit(0)
    } label: {
      Text("Close")
        .frame(maxWidth: .infinity, minHeight: 40)
        .font(.title2)
    }
    .buttonStyle(.borderedProminent)
    .padding()
  }
}
