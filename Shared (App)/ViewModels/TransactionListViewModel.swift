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
    
    @Published var viewModels: [TransactionViewModel] = []
    @Published var showDetails = false
    var transactionDetail: TransactionActivity?
    @Published var showError = false
    var errorMessage = ""
    
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
                
                let contracts = await fetchContracts(fromTxs: fetchedTransactions)
                contracts.forEach { self.contracts[$0.address] = $0 }
                
                let viewModels = fetchedTransactions.map(toViewModel)
                self.viewModels.append(contentsOf: viewModels)
                self.transactions.append(contentsOf: fetchedTransactions)
                
                isFetching = false
            } catch let error {
                //TODO: Error handling / Define error cases and appropriate error messages
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
    
    func fetchTransactionsIfNeeded(atTransactionHash txHash: String) {
        guard canLoadNextPage(atTransactionHash: txHash) else { return }
        fetchTransactions()
    }
    
    func showDetails(forTransaction tx: TransactionViewModel) {
        guard let tx = transactions.first(where: { $0.txHash == tx.hash }) else { return }
        transactionDetail = tx
        showDetails = true
    }
    
    private func canLoadNextPage(atTransactionHash txHash: String) -> Bool {
        guard let index: Int = transactions.firstIndex(where: { $0.txHash == txHash }) else { return false }
        let reachedThreshold = Double(index) / Double(transactions.count) > 0.7
        return !isFetching && reachedThreshold
    }
    
    @MainActor
    private func fetchContracts(fromTxs txs: [TransactionActivity]) async -> [Contract] {
        await withTaskGroup(of: Contract?.self) { [weak self] group in
            guard let self = self else { return [] }
            
            var contracts = [Contract]()
            var addresses = Set<RawAddress>()
            
            // Create a set of unique addresses
            txs.forEach {
                if let toAddress = $0.to?.address {
                    addresses.insert(toAddress)
                }
            }
            
            // For each unique address add a fetch task to the task group
            for address in addresses {
                guard self.contracts[address] == nil else { continue }
                group.addTask {
                    return await self.contractService.fetchContractDetails(forAddress: address)
                }
            }
            
            // Execute each fetch task and return all fetched contracts
            for await contract in group {
                guard let contract = contract else { continue }
                contracts.append(contract)
            }
            return contracts
        }
    }
    
    private func toViewModel(_ tx: TransactionActivity) -> TransactionViewModel {
        guard let toAddress = tx.to?.address, let contractName = contracts[toAddress]?.nameTag else {
            return TransactionViewModel(tx: tx, nameTags: [])
        }
        return TransactionViewModel(tx: tx, nameTags: [contractName])
    }
}

enum TransactionFilter: Int {
    case all
    case sent
    case received
    case interactions
    case failed
}
