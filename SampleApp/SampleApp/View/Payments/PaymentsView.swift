import SwiftUI
import TyroTapToPaySDK

enum InputFocus: Hashable {
  case amountTextField
  case paymentButton
  case refundButton
  case none
}

struct PaymentsView: View {
  @State var amount: Decimal = .zero
  @State var processingState: TransactionProcessingState = .ready
  @State var error: Error?
  @FocusState var isFocussed: Bool
  @State var isPresented: Bool = false

  @State var items: [Decimal] = []
  var subTotal: Decimal {
    items.reduce(0) {
      $0 + $1
    }
  }

  let processClosure: (TransactionType, Decimal) async throws -> Void

  init(processClosure: @escaping (TransactionType, Decimal) async throws -> Void) {
    self.processClosure = processClosure
  }

  var body: some View {
    VStack {
      switch processingState {
      case .ready:
        Form {
          Section(header: Text("Amount")) {
            HStack {
              Button {
                items.append(amount)
              } label: {
                Image(systemName: "plus.circle")
              }
              TextField("Amount", value: $amount, format: .currency(code: "AUD"))
                .keyboardType(.decimalPad)
                .font(.title2)
                .focused($isFocussed)
                .toolbar {
                  ToolbarItemGroup(placement: .keyboard) {
                    HStack {
                      Spacer()
                      Button() {
                        isFocussed.toggle()
                        isPresented.toggle()
                      } label: {
                        Text("Done")
                      }
                    }
                  }
                }
            }
          }
          if !items.isEmpty {
            Section(header: Text("Items")) {
              List {
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                  HStack {
                    Button {
                      items.remove(at: index)
                    } label: {
                      Image(systemName: "minus.circle")
                    }
                    Text(item, format: .currency(code: "AUD"))
                      .frame(maxWidth: .infinity, alignment: .trailing)
                  }

                }
              }
            }
            Section(header: Text("Sub-total")) {
              HStack {
                Spacer()
                Text(subTotal.formatted(.currency(code: "AUD")))
                  .multilineTextAlignment(.trailing)
              }
            }
          }
        }
        .multilineTextAlignment(.trailing)
        .confirmationDialog("Actions", isPresented: $isPresented) {
          Button {
            Task {
              do {
                try await processClosure(.payment, items.isEmpty ? amount : subTotal)
              } catch {
                self.error = error
              }
            }
          } label: {
            Text("Payment")
              .font(.callout)
              .fontWeight(.semibold)
              .frame(maxWidth: .infinity)
          }
          .buttonStyle(BorderedProminentButtonStyle())

          Button(role: .destructive) {
            Task {
              do {
                try await processClosure(.refund, items.isEmpty ? amount : subTotal)
              } catch {
                self.error = error
              }
            }
          } label: {
            Text("Refund")
              .font(.callout)
              .fontWeight(.semibold)
              .frame(maxWidth: .infinity)
          }
          .buttonStyle(BorderedProminentButtonStyle())
          .frame(maxWidth: .infinity)
        }
        .onSubmit {
          isPresented.toggle()
        }
        .onAppear {
          isFocussed = true
        }
        Button {
          isPresented.toggle()
        } label: {
          Text("Transact")
            .frame(maxWidth: .infinity, minHeight: 40)
            .font(.title2)
            .ignoresSafeArea()
        }
        .buttonStyle(BorderedProminentButtonStyle())
        .padding()
        .disabled(amount.isZero)

      case .inProgress(let transactionType, let amount):
        VStack(alignment: .center, spacing: 10) {
          HStack(alignment: .center, spacing: 10) {
            ProgressView()
            Text("Processing \(transactionType.rawValue) for \(amount)...")
          }
          Spacer()
        }
        .frame(maxWidth: .infinity, minHeight: 200)
        .padding()

      case .failed(let error):
        VStack(alignment: .center, spacing: 10) {
          Spacer()
          Image(systemName: "x.circle.fill")
            .resizable()
            .frame(minWidth: 200, minHeight: 200)
          Text(error.localizedDescription)
            .font(.title2)
          Button {
            withAnimation(.easeInOut(duration: 2)) {
              processingState = .ready
            }
          } label: {
            Text("Reset")
          }
          Spacer()
        }
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}

#Preview {
  @State var amount: Decimal = .zero
  return PaymentsView { (transactionType, amountText) in
    print("\(transactionType.rawValue) \(amountText)")
  }
}
