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
                            description: "none",
                            toAddress: tx.toAddress ?? "", // TODO: distinguish between contract address and send from or to
                            token: tx.token,
                            fiat: tx.fiat
                        )
                            .padding([.top, .bottom], 8)
                            .onAppear {
//                                viewModel.fetchTransactionsIfNeeded(currentTransaction: transactionGroup)
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
    
    struct TransactionsView_Previews: PreviewProvider {
        static var previews: some View {
            TransactionsView(viewModel: TransactionsListViewModel(chain: "1",
                                                                  address: "ric.eth",
                                                                  currency: "USD",
                                                                  symbol: "$"))
        }
    }
}
