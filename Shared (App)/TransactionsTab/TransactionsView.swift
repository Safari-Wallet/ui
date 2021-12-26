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
                Section {
                    Picker("Mode", selection: $viewModel.filter, content: {
                        Text("All").tag(TransactionFilter.all)
                        Text("Sent").tag(TransactionFilter.sent)
                        Text("Received").tag(TransactionFilter.received)
                        Text("Interactions").tag(TransactionFilter.interactions)
                        Text("Failed").tag(TransactionFilter.failed)
                    })
                        .pickerStyle(SegmentedPickerStyle())
                    List {
                        switch viewModel.state {
                        case .loading:
                            HStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                        case .fetched(txs: let txs):
                            ForEach(txs) { transactionGroup in
                                NavigationLink(destination: TransactionDetailsView(group: transactionGroup)) {
                                    TransactionRowView(
                                        txType: TransactionType(transactionGroup.type),
                                        description: transactionGroup.inputDescription ?? transactionGroup.methodName ?? transactionGroup.description,
//                                        toAddress: transactionGroup.toAddress,
                                        toAddress: transactionGroup.contractName ?? "",
                                        amount: transactionGroup.value
                                    )
                                    .onAppear {
                                        viewModel.fetchTransactionsIfNeeded(currentTransaction: transactionGroup)
                                    }
                                }
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
                    .listStyle(.plain)
                }
            }.navigationBarHidden(true)
        }
    }
}

struct TransactionRow: View {
    
    let transactionGroup: TransactionGroup
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Hash: \(transactionGroup.transactionHash)")
                .font(.headline)
                .bold()
                .lineLimit(1)
                .truncationMode(.tail)
            HStack {
                Text(transactionGroup.fromAddress)
                    .lineLimit(1)
                    .truncationMode(.middle)
                Spacer()
                Image(systemName: "arrow.right")
                    .foregroundColor(.blue)
                    .unredacted()
                Spacer()
                Text(transactionGroup.toAddress)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            Text("\(transactionGroup.transactions.count) sources")
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
