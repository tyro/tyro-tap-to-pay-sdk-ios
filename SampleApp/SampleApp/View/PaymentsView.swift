import SwiftUI
import TyroTapToPaySDK

class PaymentsViewModel: ObservableObject {
  @Published var amount: String = ""
  @Published var processInProgress: String?
  @Published var showError: Bool = false
  @Published var error: String? {
    didSet {
      showError = true
    }
  }

  private let tapToPaySDK: TyroTapToPay

  let posInfo = POSInformation(name: "Demo",
                               vendor: "Tyro Payments Sample App",
                               version: "1.0",
                               siteReference: "Sydney")

  init(tapToPaySDK: TyroTapToPay) {
    self.amount = ""
    self.tapToPaySDK = tapToPaySDK
  }

  func connect() async {
    processInProgress = "Initialising..."
    defer {
      processInProgress = nil
    }
    do {
      try await self.tapToPaySDK.connect()
    } catch {
      self.error = "\(error)"
    }
  }

  func startPayment() async {
    guard isAAmountValid(amount), let amountDecimal = Decimal(string: amount) else {
      error = "Wrong amount format"
      return
    }
    let amountInCents = amountDecimal * 100.0
    let transactionDetail = TransactionDetail(amount: "\(amountInCents)",
                                              referenceNumber: "your reference number",
                                              transactionID: "your transaction id",
                                              cardIsPresented: true,
                                              email: "customer email address",
                                              mobilePhoneNumber: "customer mobile phone number",
                                              posInformation: posInfo,
                                              localeLanguage: Locale.current.language)
    do {
      let outcome = try await tapToPaySDK.startPayment(transactionDetail: transactionDetail)
      print(outcome)
    } catch {
      self.error = "\(error)"
    }
  }

  func startRefund() {
    guard isAAmountValid(amount) else {
      error = "Wrong amount format"
      return
    }

  }

  private func isAAmountValid(_ amount: String) -> Bool {
    if let _ = try? /(\d+(\.\d{2})?)/.wholeMatch(in: amount) {
      return true
    } else {
      return false
    }
  }
}

struct PaymentsView: View {
  @ObservedObject var viewModel: PaymentsViewModel

  init(viewModel: PaymentsViewModel) {
    self.viewModel = viewModel
  }

  var body: some View {
    ZStack {
      if let processInProgress = viewModel.processInProgress {
        VStack {
          HStack(spacing: 10) {
            ProgressView()
            Text(processInProgress)
          }
          Spacer()
        }
        .padding()
      }
      VStack {
//        TextField("Amount", value: $viewModel.amount, format: .currency(code: .))
        TextField("Amount", text: $viewModel.amount, prompt: Text("$0.00"))
          .keyboardType(.decimalPad)

          .font(.largeTitle)
          .multilineTextAlignment(.center)
          .padding()
        HStack {
          Button {
            Task {
              await viewModel.startPayment()
            }
          } label: {
            Text("Payment")
          }
          .frame(maxWidth: .infinity)
          .buttonStyle(.borderedProminent)
          .disabled(viewModel.processInProgress != nil)

          Button {
            viewModel.startRefund()
          } label: {
            Text("Refund")
          }
          .frame(maxWidth: .infinity)
          .buttonStyle(.bordered)
          .disabled(viewModel.processInProgress != nil)
        }
        .padding(.top)
      }
      .padding()
    }
    .alert("Error", isPresented: $viewModel.showError, presenting: viewModel.error, actions: { _ in
      Button("Cancel", role: .cancel, action: {})
    }, message: { error in
      Text(error)
    })
    .task {
      await viewModel.connect()
    }
  }
}

#Preview {
  PaymentsView(viewModel: PaymentsViewModel(tapToPaySDK: TyroTapToPay(environment: .sandbox,
                                                                      connectionProvider: SandboxConnectionProvider(restClient: TyroRestClient(environment: .sandbox)))))
}
