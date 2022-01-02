//
//  TransactionsViewModel.swift
//  Wallet
//
//  Created by Nathan Clark on 10/30/21.
//

import Foundation
import SafariWalletCore
import MEWwalletKit

final class TransactionsListViewModel: ObservableObject {
    
    // TODO: show error
    @Published var viewModels: [TransactionViewModel] = []
    
    private var transactions: [TransactionActivity] = []
    // TODO: Implement contract caching
    private var contracts: [String: Contract] = [:]
    
    private let chain: String
    private let address: String
    private let currency: String
    private let symbol: String
    
    private var isFetching = false
    
    private let txService: TransactionFetchable
    private let contractService: ContractFetchable
    
    init(chain: String,
         address: String,
         currency: String,
         symbol: String,
         txService: TransactionFetchable = TransactionService(),
         contractService: ContractFetchable = ContractService()
    ) {
        self.chain = chain
        self.address = address
        self.currency = currency
        self.symbol = symbol
        self.txService = txService
        self.contractService = contractService
        fetchTransactions()
    }
    
    func fetchTransactions() {
        guard let address = Address(ethereumAddress: address) else { return }
        isFetching = true
        Task {
            do {
                let fetchedTransactions = try await self.txService.fetchTransactions(network: .ethereum, address: address)
                await fetchContracts(fromTxs: fetchedTransactions)
                print(contracts)
                // TODO: Add contract name
                let viewModels = fetchedTransactions.map(TransactionViewModel.init)
                self.viewModels.append(contentsOf: viewModels)
                self.transactions = fetchedTransactions
                isFetching = false
            } catch let error {
                //TODO: Error handling / Define error cases and appropriate error messages
                print(error)
            }
        }
    }
    
    func fetchTransactionsIfNeeded(atTransactionHash txHash: String) {
        guard canLoadNextPage(atTransactionHash: txHash) else { return }
        fetchTransactions()
    }
    
    private func canLoadNextPage(atTransactionHash txHash: String) -> Bool {
        guard let index: Int = transactions.firstIndex(where: { $0.txHash == txHash }) else { return false }
        let reachedThreshold = Double(index) / Double(transactions.count) > 0.7
        return !isFetching && reachedThreshold
    }
    
    @MainActor
    private func fetchContracts(fromTxs txs: [TransactionActivity]) async {
        var contracts = [Contract]()
        await withTaskGroup(of: Contract?.self) { [weak self] group in
            guard let self = self else { return }
            for tx in txs {
                group.addTask {
                    guard //tx.type != .execution,
                          let contractAddress = tx.to,
                          self.contracts[contractAddress.address] == nil else { return nil }
                    return try? await self.contractService.fetchContractDetails(forAddress: contractAddress)
                }
                for await contract in group {
                    guard let contract = contract else { return }
                    contracts.append(contract)
                }
            }
        }
        for contract in contracts {
            self.contracts[contract.address] = contract
        }
    }
}

enum TransactionFilter: Int {
    case all
    case sent
    case received
    case interactions
    case failed
}
