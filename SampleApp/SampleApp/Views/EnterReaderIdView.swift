//
//  EnterReaderIdView.swift
//  Tyro Embedded Sample App
//
//  Created by Sanjay Narayana on 2/7/2024.
//

import Foundation
import SwiftUI

struct EnterReaderIdView: View {
  @State private var viewModel: ViewModel
  @FocusState private var isFocused: Bool
  var onSubmitReaderId: (_ readerId: String) -> Void

  init(onSubmitReaderId: @escaping (_: String) -> Void) {
    self.viewModel = ViewModel()
    self.onSubmitReaderId = onSubmitReaderId
  }

  var body: some View {
    Text("Enter your Reader ID below")
    Form {
      Section(header: Text("Reader id")) {
        VStack {
          TextField("", text: $viewModel.readerId)
            .focused($isFocused)
            .autocapitalization(.none)
            .onAppear {
              DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                self.isFocused = true
              }
            }
        }
      }
      Section {
        ForEach(viewModel.savedReaders.reversed(), id: \.self) { readerId in
          Button {
            viewModel.selectReader(selectedReaderId: readerId)
          } label: {
            HStack {
              Image(systemName: "clock")
              Text(readerId)
            }
          }
          .font(.subheadline)
          .foregroundColor(.gray)
        }

        if viewModel.savedReaders.count > 0 {
          Button {
            viewModel.clearSavedReaders()
          } label: {
            Text("Clear saved readers")
              .frame(maxWidth: .infinity, minHeight: 30)
              .font(.subheadline)
          }
          .padding(.horizontal)
          .buttonStyle(.plain)
        }
      }
    }

    Button {
      if viewModel.isValidReaderId() {
        isFocused = false
        viewModel.saveReader()
        self.onSubmitReaderId(viewModel.readerId)
      }
    } label: {
      Text("Confirm")
        .frame(maxWidth: .infinity, minHeight: 40)
        .font(.title2)
        .ignoresSafeArea()
    }
    .padding()
    .buttonStyle(.borderedProminent)
    .disabled(!viewModel.isValidReaderId())
  }
}

extension EnterReaderIdView {
  @Observable
  class ViewModel: ObservableObject {
    let SAVED_READERS_KEY = "tyro-reader-ids"
    var savedReaders: [String] = []
    var readerId: String = ""
    var isPresented: Bool = false

    init() {
      savedReaders =
        UserDefaults.standard.object(forKey: SAVED_READERS_KEY) as? [String] ?? [String]()
      if savedReaders.count > 0 {
        readerId = savedReaders.last ?? ""
      }
    }

    func isValidReaderId() -> Bool {
      return readerId.count > 0
    }

    func saveReader() {
      var readersToSave = savedReaders
      readersToSave.append(readerId)
      readersToSave = readersToSave.unique()
      UserDefaults.standard.set(readersToSave, forKey: SAVED_READERS_KEY)
      savedReaders = readersToSave
    }

    func selectReader(selectedReaderId: String) {
      self.readerId = selectedReaderId
    }

    func clearSavedReaders() {
      savedReaders = []
      UserDefaults.standard.set([], forKey: SAVED_READERS_KEY)
    }
  }
}

extension Sequence where Iterator.Element: Hashable {
  func unique() -> [Iterator.Element] {
    var visited: Set<Iterator.Element> = []
    return filter { visited.insert($0).inserted }
  }
}

#Preview {
  EnterReaderIdView(onSubmitReaderId: {
    print($0)
  })
}
