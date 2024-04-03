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

  let processClosure: (TransactionType, String) async throws -> Void

  init(processClosure: @escaping (TransactionType, String) async throws -> Void) {
    self.processClosure = processClosure
  }

  var body: some View {
    VStack {
      switch processingState {
      case .ready:
        Form {
          Section(header: Text("Amount")) {
            HStack {
              TextField("Amount", value: $amount, format: .currency(code: "AUD"))
                .formStyle(.grouped)
                .keyboardType(.decimalPad)
                .focused($isFocussed)
              Button {
                isPresented.toggle()
              } label: {
                Image(systemName: "plus.circle")
              }
            }
          }
        }
        .confirmationDialog("Actions", isPresented: $isPresented) {
          Button {
            Task {
              do {
                try await processClosure(.payment, amount.formatted(.currency(code: "AUD")))
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
                try await processClosure(.refund, amount.formatted(.currency(code: "AUD")))
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
        .multilineTextAlignment(.trailing)
        .onSubmit {
          isPresented.toggle()
        }
        .onAppear {
          isFocussed = true
        }

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
