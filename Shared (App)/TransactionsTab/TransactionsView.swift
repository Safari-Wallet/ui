//
//  TransactionsView.swift
//  Wallet
//
//  Created by Ronald Mannak on 10/14/21.
//

import SwiftUI

struct TransactionsView: View {
    
    @ObservedObject var viewModel: TransactionsListViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(viewModel.viewModels) { tx in
                        TransactionRowView(
                            txType: tx.type,
                            toAddress: tx.toAddress ?? "", // TODO: distinguish between contract address and send from or to
                            token: tx.token,
                            fiat: tx.fiat,
                            nameTag: tx.tags.first,
                            description: tx.description
                        )
                            .padding([.top, .bottom], 8)
                            .onAppear {
                                viewModel.fetchTransactionsIfNeeded(atTransactionHash: tx.hash)
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
        .notification(show: $viewModel.showError, text: viewModel.errorMessage)
    }
    
    struct TransactionsView_Previews: PreviewProvider {
        static var previews: some View {
            TransactionsView(viewModel: TransactionsListViewModel(chain: "1",
                                                                  address: "ric.eth",
                                                                  currency: "USD",
                                                                  symbol: "$"))
        }
    }
}
