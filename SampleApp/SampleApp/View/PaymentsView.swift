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

  @MainActor
  func connect() async {
    processInProgress = "Initialising..."
    defer {
      processInProgress = nil
    }
    Task {
      do {
        try await self.tapToPaySDK.connect()
      } catch {
        await MainActor.run {
          self.error = "\(error)"
        }
      }
    }
  }

  func startPayment() async {
    guard isValidAmount(amount), let amountDecimal = Decimal(string: amount) else {
      error = "Wrong amount format"
      return
    }
    let amountInCents = amountDecimal * 100.0
    let transactionDetail = TransactionDetail(amount: "\(amountInCents)",
                                              referenceNumber: UUID().uuidString,
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

  func startRefund() async {
    guard isValidAmount(amount), let amountDecimal = Decimal(string: amount) else {
      error = "Wrong amount format"
      return
    }
    let amountInCents = amountDecimal * 100.0
    let transactionDetail = TransactionDetail(amount: "\(amountInCents)",
                                              referenceNumber: UUID().uuidString,
                                              transactionID: "your transaction id",
                                              cardIsPresented: true,
                                              email: "customer email address",
                                              mobilePhoneNumber: "customer mobile phone number",
                                              posInformation: posInfo,
                                              localeLanguage: Locale.current.language)
    do {
      let outcome = try await tapToPaySDK.refundPayment(transactionDetail: transactionDetail)
      print(outcome)
    } catch (let error) {
      self.error = "\(error)"
    }
  }

  private func isValidAmount(_ amount: String) -> Bool {
    if let _ = try? /(\d+(\.\d{2})?)/.wholeMatch(in: amount) {
      return true
    } else {
      return false
    }
  }
}

struct PaymentsView: View {
  @ObservedObject var viewModel: PaymentsViewModel
  @FocusState var inputFocus: InputFocus?

  enum InputFocus: Hashable {
    case amountTextField
    case paymentButton
    case refundButton
  }

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
        TextField("Amount", text: $viewModel.amount, prompt: Text("$0.00"))
          .keyboardType(.decimalPad)
          .font(.largeTitle)
          .multilineTextAlignment(.center)
          .padding()
          .focused($inputFocus, equals: .amountTextField)
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
          .focused($inputFocus, equals: .paymentButton)

          Button {
            Task {
              await viewModel.startRefund()
            }
          } label: {
            Text("Refund")
          }
          .frame(maxWidth: .infinity)
          .buttonStyle(.bordered)
          .disabled(viewModel.processInProgress != nil)
          .focused($inputFocus, equals: .refundButton)
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
      inputFocus = .amountTextField
      await viewModel.connect()
    }
  }
}

#Preview {
  PaymentsView(
    viewModel: PaymentsViewModel(
      tapToPaySDK: try! TyroTapToPay(
        environment: .sandbox,
        connectionProvider: SandboxConnectionProvider(restClient: TyroRestClient(environment: .sandbox))
      )
    )
  )
}
