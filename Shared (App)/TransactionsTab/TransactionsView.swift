//
//  TransactionsView.swift
//  Wallet
//
//  Created by Ronald Mannak on 10/14/21.
//

import SwiftUI

struct TransactionsView: View {
    
    @StateObject var viewModel: TransactionsListViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isFetching { ProgressView() }
//                if viewModel.viewModels.isEmpty { Text("Looks empty 👻") }
                VStack {
                    List {
                        ForEach(viewModel.viewModels) { tx in
                            TransactionRowView(
                                txType: tx.type,
                                toAddress: tx.toAddress ?? "",
                                token: tx.token,
                                fiat: tx.fiat,
                                nameTag: tx.tags.first,
                                description: tx.description,
                                date: tx.date
                            )
                                .padding([.top, .bottom], 8)
                                .contentShape(Rectangle())
                                .onAppear {
                                    viewModel.fetchTransactionsIfNeeded(atTransactionHash: tx.hash)
                                }
                                .onTapGesture {
                                    viewModel.showDetails(forTransaction: tx)
                                }
                        }
                    }
                    .refreshable {
                        viewModel.fetchTransactions()
                    }
                    .listStyle(.plain)
                    .navigationTitle("Transactions")
                }
            }
        }
        .notification(show: $viewModel.showError, text: viewModel.errorMessage)
        .sheet(isPresented: $viewModel.showDetails) {
            NavigationView {
                HStack {
                    Text("View on Etherscan")
                    Image(systemName: "arrow.up.forward.square")
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    guard let tx = viewModel.transactionDetail,
                          let url = URL(string: "https://etherscan.io/tx/\(tx.txHash)") else { return }
                    UIApplication.shared.open(url) { _ in
                        viewModel.showDetails = false
                    }
                }
            }
        }
    }
    
    struct TransactionsView_Previews: PreviewProvider {
        static var previews: some View {
            TransactionsView(
                viewModel: TransactionsListViewModel(
                    network: .ethereum,
                    address: "ric.eth",
                    currency: "USD",
                    symbol: "$",
                    userSettings: UserSettings()
                )
            )
        }
    }
}
