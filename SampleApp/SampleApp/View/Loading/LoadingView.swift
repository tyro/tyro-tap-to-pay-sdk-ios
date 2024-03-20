//
//  LoadingView.swift
//  SampleApp
//
//  Created by Christopher Grantham on 20/3/2024.
//

import SwiftUI
import TyroTapToPaySDK

struct LoadingView: View {
  @Binding var loadingState: LoadingState

  var body: some View {
    VStack {
      Spacer()
      switch loadingState {
      case .inProgress(let title):
        ProgressView() {
          Text(title)
            .font(.title)
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .foregroundStyle(.secondary)
      case .ready:
        VStack {
          Image(systemName: "checkmark.circle")
            .resizable()
            .frame(maxWidth: 100, maxHeight: 100)
          Text("Ready!")
            .font(.title)
        }
        .foregroundStyle(.green)
      case .failure(let error):
        VStack {
          Image(systemName: "x.circle.fill")
            .resizable()
            .ignoresSafeArea()
          Text(error.localizedDescription)
            .font(.title)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .foregroundStyle(.red)
      }
      Spacer()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}
//
//#Preview("Loading") {
//  @Binding var loadingState: LoadingState = .inProgress("Loading...")
//  return LoadingView(loadingState: $loadingState)
//}
//
//#Preview("Ready") {
//  @Binding var loadingState: LoadingState = .ready
//  return LoadingView(loadingState: $loadingState)
//}
//
//#Preview("Error") {
//  @Binding var loadingState: LoadingState = .failure
//  return LoadingView(loadingState: $loadingState)
//}
