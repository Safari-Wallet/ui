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
        VStack {
            Section {
                Picker("Mode", selection: $viewModel.filter, content: {
                    Text("All").tag(TransactionFilter.all)
                    Text("Sent").tag(TransactionFilter.sent)
                    Text("Received").tag(TransactionFilter.received)
                    //                        Text("Interactions").tag(TransactionFilter.interactions)
                    //                        Text("Failed").tag(TransactionFilter.failed)
                })
                    .pickerStyle(SegmentedPickerStyle())
                List {
                    switch viewModel.state {
                    case .loading:
                        ForEach(1..<6) { tx in
//                            TransactionRow(tx: .placeholder)
//                                .redacted(reason: .placeholder)
                        }
                    case .fetched(txs: let txs):
                        ForEach(txs) { tx in
                            TransactionRow(tx: tx)
                        }
                    case .error(message: let message):
                        // Simple error msg for now
                        Text(message)
                        Spacer()
                    }
                }
                .refreshable {
                    viewModel.fetchTransactions()
                }
            }
        }
    }
}

struct TransactionRow: View {
    
    let tx: WalletTransactionType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Tx type: \(tx.transaction.type)")
                .font(.headline)
                .bold()
            HStack {
                Text(tx.transaction.from.address)
                    .lineLimit(1)
                    .truncationMode(.middle)
                Spacer()
                Image(systemName: "arrow.right")
                    .foregroundColor(.blue)
                    .unredacted()
                Spacer()
                Text(tx.transaction.to.address)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            Text("\(tx.transaction.value) \("USD")")
                .font(.system(size: 24.0, weight: .bold, design: .rounded))
        }
        .frame(maxWidth: .infinity)
        .padding()
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
