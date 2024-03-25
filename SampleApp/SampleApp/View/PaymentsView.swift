import SwiftUI
import TyroTapToPaySDK

struct PaymentsView: View {
  @State private var isLoading: Bool = true
  @State private var paymentInProgress: Bool = false
  @State private var amount: String = ""
  @State private var displayMessage: String = ""
  @FocusState private var isFocused: Bool

  private var tapToPaySDK: TyroTapToPay
  private let demoPosInfo = POSInformation(
    name: "Demo",
    vendor: "Tyro Payments Sample App",
    version: "1.0",
    siteReference: "Sydney"
  )

  init(tapToPaySDK: TyroTapToPay) {
    self.tapToPaySDK = tapToPaySDK
    self.isFocused = true
  }

  @MainActor
  func connect() async {
    defer {
      isLoading = false
    }
    do {
      try await tapToPaySDK.connect()
    } catch (let error) {
      await MainActor.run {
        displayMessage = "Something went wrong when connecting: \(error)"
      }
    }
  }

  func startRefund() async {
    isFocused = false
    displayMessage = ""
    guard isValidAmount(amount), let amountDecimal = Decimal(string: amount) else {
      displayMessage = "Wrong amount format"
      return
    }
    defer {
      paymentInProgress = false
    }
    let transactionDetail = buildDemoTransactionDetail(amount: amountDecimal)
    do {
      displayMessage = "Refund in progress..."
      paymentInProgress = true
      let outcome = try await tapToPaySDK.refundPayment(transactionDetail: transactionDetail)
      displayMessage = "Refund successful: \(outcome)"
    } catch (let error) {
      displayMessage = "Something went wrong when refunding: \(error)"
    }
  }

  func startPayment() async {
    displayMessage = ""
    isFocused = false
    guard isValidAmount(amount), let amountDecimal = Decimal(string: amount) else {
      displayMessage = "Wrong amount format"
      return
    }
    let transactionDetail = buildDemoTransactionDetail(amount: amountDecimal)
    defer {
      paymentInProgress = false
    }
    do {
      paymentInProgress = true
      displayMessage = "Payment in progress..."
      let outcome = try await tapToPaySDK.startPayment(transactionDetail: transactionDetail)
      displayMessage = "Payment successful: \(outcome)"
    } catch TapToPaySDKError.fetchSessionCredentialsError(let error) {
      displayMessage = "Failed to fetch session credentials: \(error)"
    } catch TapToPaySDKError.transactionError(let error) {
      displayMessage = "Transaction error: \(error)"
    } catch {
      displayMessage = "Something went wrong when paying: \(error)"
    }
  }

  // MARK: - helper functions
  private func buildDemoTransactionDetail(amount: Decimal) -> TransactionDetail {
    let amountInCents = amount * 100.0
    return TransactionDetail(
      amount: "\(amountInCents)",
      referenceNumber: UUID().uuidString,
      transactionID: "transaction id",
      cardIsPresented: true,
      email: "customer's email address",
      mobilePhoneNumber: "customer's mobile phone number",
      posInformation: demoPosInfo,
      localeLanguage: Locale.current.language
    )
  }

  private func reset() {
    paymentInProgress = false
    isFocused = false
    displayMessage = ""
    amount = ""
  }

  private func isValidAmount(_ amount: String) -> Bool {
    if let _ = try? /(\d+(\.\d{2})?)/.wholeMatch(in: amount) {
      return true
    } else {
      return false
    }
  }

  // MARK: - View
  var body: some View {
    Image(.tyroLogo)
      .resizable()
      .aspectRatio(contentMode: .fit)
      .frame(maxWidth: 150)
    ZStack {
      if isLoading {
        VStack {
          HStack {
            ProgressView()
            Text("Loading...")
              .padding()
          }.frame(
            maxWidth: .infinity,
            alignment: .center
          )
          Spacer()
        }
        .padding()
      } else {
        VStack {
          TextField("Amount", text: $amount, prompt: Text("$0.00"))
            .keyboardType(.decimalPad)
            .font(.largeTitle)
            .multilineTextAlignment(.center)
            .focused($isFocused)
            .padding()
          HStack {
            Button("Payment") {
              Task {
                await startPayment()
              }
            }
            .disabled(isLoading)
            .frame(maxWidth: .infinity)
            .buttonStyle(.borderedProminent)
            Button("Refund") {
              Task {
                await startRefund()
              }
            }
            .frame(maxWidth: .infinity)
            .buttonStyle(.bordered)
            .disabled(isLoading)
          }
          Button("Reset") {
            reset()
          }
          Text(displayMessage)
            .padding(.top)
        }.disabled(paymentInProgress)
          .padding()
      }
    }.onAppear {
      Task {
        await self.connect()
      }
    }
  }
}

#Preview {
  PaymentsView(
    tapToPaySDK: try! TyroTapToPay(
      environment: .sandbox,
      connectionProvider: SandboxConnectionProvider(
        restClient: TyroRestClient(environment: .sandbox))
    )
  )
}
