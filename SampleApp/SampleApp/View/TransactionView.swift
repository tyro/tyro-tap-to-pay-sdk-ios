//
//  TransactionView.swift
//  SampleApp
//
//  Created by Ronaldo Gomes on 22/9/2023.
//

import SwiftUI
import TyroTapToPaySDK

enum TransactionType: String, CaseIterable, Identifiable, CustomStringConvertible {
  case payment
  case refund
  var id: String { self.rawValue }
  
  var description: String {
    return self.rawValue.capitalized
  }
}

struct TransactionView: View {
  @State private var referenceNumber: String = UUID().uuidString
  @State private var cost: String = ""
  @FocusState private var keyboardFocus: Bool
  @State var showAlert: Bool = false
  
  @State private var transactionType: TransactionType = .payment
  
  let numberFormatter: NumberFormatter
  
  init() {
    numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .currency
    numberFormatter.maximumFractionDigits = 2
    numberFormatter.locale = Locale.current
  }
  
  var body: some View {
    VStack {
      Form {
        Section {
          LabeledContent {
            TextField("", text: $referenceNumber)
              .font(.system(size: 10.0, weight: .semibold))
              .disabled(true)
              .multilineTextAlignment(.center).listRowSeparator(.hidden)
          } label: { Text("Reference Number") }
          
          LabeledContent {
            TextField("Amount", text: $cost)
              .font(.system(size: 36.0, weight: .semibold))
              .disabled(true)
              .multilineTextAlignment(.center).listRowSeparator(.hidden)
          } label: { Text("Amount") }
          
          
          Picker("Transaction Type", selection: $transactionType) {
            Text(TransactionType.payment.description).tag(TransactionType.payment)
            Text(TransactionType.refund.description).tag(TransactionType.refund)
          }.pickerStyle(SegmentedPickerStyle()).listRowSeparator(.hidden)
          
          HStack {
            CalcButton(value: 1, cost: $cost)
            CalcButton(value: 2, cost: $cost)
            CalcButton(value: 3, cost: $cost)
          }
          .frame(minWidth: 0, maxWidth: .infinity).listRowSeparator(.hidden)
          HStack {
            CalcButton(value: 4, cost: $cost)
            CalcButton(value: 5, cost: $cost)
            CalcButton(value: 6, cost: $cost)
          }.frame(minWidth: 0, maxWidth: .infinity).listRowSeparator(.hidden)
          HStack {
            CalcButton(value: 7, cost: $cost)
            CalcButton(value: 8, cost: $cost)
            CalcButton(value: 9, cost: $cost)
          }.frame(minWidth: 0, maxWidth: .infinity).listRowSeparator(.hidden)
          HStack {
            PeriodButton(cost: $cost)
            CalcButton(value: 0, cost: $cost)
            CleanButton(cost: $cost)
          }.frame(minWidth: 0, maxWidth: .infinity).listRowSeparator(.hidden)
          
          Button {
            if !self.cost.isEmpty {
              var cost = Decimal(string: self.cost)!
              if self.cost.contains(".") {
                cost = cost * 100
              }
              
              let transactionDetail = TransactionDetail.Builder()
                .setAmount("\(cost)")
                .setReferenceNo(referenceNumber)
                .build()
              Task {
                do {
                  if transactionType == .payment {
                    _ = try await TyroTapToPay.shared.startPayment(transactionDetail: transactionDetail)
                  } else {
//                    _ = try await TyroTapToPay.shared.startRefund(transactionDetail: transactionDetail)
                  }
                } catch let error {
                  _ = Alert(title: Text(error.localizedDescription))
                }
              }
            } else {
              showAlert.toggle()
            }
            
          } label: {
            Label("Tap to Pay on iPhone", systemImage: "wave.3.right.circle.fill")
              .font(.system(size: 20))
              .buttonStyle(PlainButtonStyle())
          }.alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text("Please, enter value"), dismissButton: .default(Text("Close")))
          }
          .frame(maxWidth: .infinity)
          .padding(.vertical, 20)
          .foregroundColor(.white)
          .background(.blue)
          .cornerRadius(8)
        }
      }
    }
  }
}

struct CalcButton: View {
  var value: Int
  @Binding var cost: String
  var body: some View {
    Button {
      let index = cost.firstIndex(of: ".")
      if !cost.contains(".") || cost[index!...].count < 3 {
        self.cost = "\(self.cost)\(value)"
      }
    } label: {
      Text(String(value))
        .font(.system(size: 30))
    }
    .id(value)
    .buttonStyle(PlainButtonStyle())
    .padding(.horizontal, 30)
    .padding(.vertical, 30)
    .foregroundColor(.white)
    .background(.blue)
    .cornerRadius(8)
  }
  
  private func rectReader(_ binding: Binding<CGFloat>) -> some View {
    return GeometryReader { gp -> Color in
      DispatchQueue.main.async {
        binding.wrappedValue = max(binding.wrappedValue, gp.frame(in: .local).width)
      }
      return Color.blue
    }
  }
}

struct PeriodButton: View {
  @Binding var cost: String
  var body: some View {
    Button{
      if !self.cost.isEmpty && !cost.contains(".") {
        self.cost = "\(self.cost)."
      }
    } label: {
      Text(".")
        .font(.system(size: 25))
    }
    .buttonStyle(PlainButtonStyle())
    .padding(.horizontal, 35)
    .padding(.vertical, 33)
    .foregroundColor(.white)
    .background(.blue)
    .cornerRadius(8)
  }
}

struct CleanButton: View {
  @Binding var cost: String
  var body: some View {
    Button {
      self.cost = "\(self.cost.dropLast())"
    } label: {
      Image(systemName: "delete.left.fill")
        .font(.system(size: 20))
    }
    .buttonStyle(PlainButtonStyle())
    .padding(.horizontal, 28)
    .padding(.vertical, 37)
    .foregroundColor(.white)
    .background(.blue)
    .cornerRadius(8)

  }
}
