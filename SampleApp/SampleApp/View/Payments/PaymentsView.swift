import SwiftUI
import TyroTapToPaySDK

enum InputFocus: Hashable {
  case amountTextField
  case paymentButton
  case refundButton
  case none
}

struct PaymentsView: View {
  @State var processingState: TransactionProcessingState = .ready
  @State var error: Error?
  @State var items: [Decimal] = []

  let processClosure: (TransactionType, Decimal) async throws -> Void

  init(processClosure: @escaping (TransactionType, Decimal) async throws -> Void) {
    self.processClosure = processClosure
  }

  var body: some View {
    VStack {
      switch processingState {
      case .ready:
        PaymentForm(error: $error, processClosure: processClosure)
          .multilineTextAlignment(.trailing)

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

struct PaymentForm: View {
  @State var amount: Decimal = .zero
  @FocusState var isFocussed: Bool
  @State var isPresented: Bool = false
  @State var items: [Decimal] = []
  @Binding var error: Error?

  var subTotal: Decimal {
    items.reduce(0) {
      $0 + $1
    }
  }

  let processClosure: (TransactionType, Decimal) async throws -> Void

  var body: some View {
    Form {
      Section(header: Text("Amount")) {
        HStack {
          Button {
            items.append(amount)
          } label: {
            Image(systemName: "plus.circle")
          }
          .disabled(!amount.isNormal)
          TextField("Amount",
                    value: $amount,
                    format: .currency(code: "AUD").precision(.fractionLength(2)),
                    prompt: Text("Amount"))
          .keyboardType(.decimalPad)
          .focused($isFocussed)
          .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
              Spacer()
              Button("Done") {
                isFocussed = false
              }
              .disabled(!amount.isNormal)
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
    .onSubmit {
      if (items.isEmpty ? amount : subTotal).isNormal {
        isPresented = true
      }
    }
    .onAppear {
      isFocussed = true
    }
    Button {
      isPresented = true
    } label: {
      Text("Transact")
        .frame(maxWidth: .infinity, minHeight: 40)
        .font(.title2)
        .ignoresSafeArea()
    }
    .buttonStyle(BorderedProminentButtonStyle())
    .disabled(!amount.isNormal)
    .padding()
    .confirmationDialog("Actions", isPresented: $isPresented) {
      Group {
        Button {
          processPayment(type: .payment)
        } label: {
          Text("Payment")
            .font(.callout)
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity)
        }
        Button(role: .destructive) {
          processPayment(type: .refund)
        } label: {
          Text("Refund")
            .font(.callout)
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity)
        }
      }
      .buttonStyle(BorderedProminentButtonStyle())
    }
  }

  func processPayment(type: TransactionType) {
    Task {
      do {
        try await processClosure(type, items.isEmpty ? amount : subTotal)
      } catch {
        self.error = error
      }
    }
  }
}

#Preview {
  @State var amount: Decimal = .zero
  return PaymentsView { (transactionType, amountText) in
    print("\(transactionType.rawValue) \(amountText)")
  }
}
