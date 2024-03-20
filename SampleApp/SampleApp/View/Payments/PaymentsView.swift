import SwiftUI
import TyroTapToPaySDK

enum InputFocus: Hashable {
  case amountTextField
  case paymentButton
  case refundButton
  case none
}

struct PaymentsView: View {
  @State var amount: Decimal
  @FocusState var amountInFocus: Bool
  @State var activeFormatter: NumberFormatter
  @State var processingState: TransactionProcessingState = .ready
  @State var transactionType: TransactionType = .payment
  let processClosure: (TransactionType, String) async throws -> Void

  let currencyFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currencyAccounting
    formatter.currencyCode = Locale.Currency(stringLiteral: "AUD").identifier
    return formatter
  }()

  let decimalFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.minimumFractionDigits = 2
    formatter.maximumFractionDigits = 2
    return formatter
  }()

  init(amount: Decimal = .zero, processClosure: @escaping (TransactionType, String) async throws -> Void) {
    self.amount = amount
    self.activeFormatter = currencyFormatter
    self.processClosure = processClosure
  }

  var body: some View {
    Form {
      switch processingState {
      case .ready:
        VStack(alignment: .center, spacing: 10) {
          TextField("Amount",
                    value: $amount,
                    formatter: activeFormatter,
                    prompt: Text("$0.00"))
          .keyboardType(.decimalPad)
          .onSubmit {
            guard let amountString = currencyFormatter
              .string(from: NSDecimalNumber(decimal: amount)) else {
              return
            }
            Task {
              do {

                try await processClosure(transactionType, amountString)
              }
              catch {

              }
            }
          }
          .onChange(of: amountInFocus, initial: true) { (_, inFocus) in
            activeFormatter = inFocus ? decimalFormatter : currencyFormatter
          }
          .backgroundStyle(.quinary)
          Picker("Transaction type", selection: $transactionType) {
            ForEach(TransactionType.allCases, id: \.self) { transactionType in
              Text(transactionType.rawValue).tag(transactionType)
            }
          }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
              amount = .zero
              transactionType = .payment
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
    .onAppear {
      amountInFocus = true
    }
  }
}

#Preview {
  PaymentsView() { (transactionType, amountString) in
    print("\(transactionType.rawValue) \(amountString)")
  }
}
