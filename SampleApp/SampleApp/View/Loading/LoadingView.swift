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
      Image(.tyroLogo)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(maxWidth: 150)
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
        HStack {
          Image(systemName: "checkmark.circle")
            .resizable()
            .frame(maxWidth: 24, maxHeight: 24)
          Text("Ready!")
            .font(.title)
        }
        .foregroundStyle(.green)
      case .failure(let error):
        VStack {
          Image(systemName: "x.circle.fill")
            .resizable()
            .frame(maxWidth: 100, maxHeight: 100)
          Text(error.localizedDescription)
            .font(.title2)
            .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .foregroundStyle(.red)
      }
      Spacer()
    }
    .padding(.horizontal, 16.0)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}

#Preview("Loading") {
  @State var loadingState: LoadingState = .inProgress("Loading")
  return LoadingView(loadingState: $loadingState)
}

#Preview("Ready") {
  @State var loadingState: LoadingState = .ready
  return LoadingView(loadingState: $loadingState)
}

#Preview("Error") {
  @State var loadingState: LoadingState = .failure(NSError(domain: "Reader error", 
                                                           code: -101,
                                                           userInfo: [
                                                            NSLocalizedFailureReasonErrorKey :
                                                              "Invalid reader id: '<reader-id-from-connection-provider>'"
                                                           ]))
  return LoadingView(loadingState: $loadingState)
}
