//
//  TransactionsViewModel.swift
//  Wallet
//
//  Created by Nathan Clark on 10/30/21.
//

import Combine
import Foundation
import SafariWalletCore
import MEWwalletKit

final class TransactionsListViewModel: ObservableObject {
    
    enum State: Equatable {
        case loading
        case fetched(txs: [TransactionGroup])
        case error(message: String)
    }
    
    @Published var state: State = .loading
    @Published var filter: TransactionFilter = .all
    private var transactions: [TransactionGroup] = []
    // TODO: Implement contract caching
    private var contracts: [String: Contract] = [:]
    
    private let chain: String
    private let address: String
    private let currency: String
    private let symbol: String
    
    private var isFetching = false
    
    private let txService: TransactionFetchable
    private let contractService: ContractFetchable
    private var cancellables = Set<AnyCancellable>()
    
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
        bindTransactionFilter()
    }
    
    func fetchTransactions() {
        guard let address = Address(ethereumAddress: address) else { return }
        isFetching = true
        Task {
            do {
                switch self.filter {
                case .all:
                    let fetchedTransactions = try await self.txService.fetchTransactions(network: .ethereum, address: address)
                    await fetchContracts(fromTxs: fetchedTransactions)
                    let txs = fetchedTransactions.map { tx -> TransactionGroup in
                        var tx = tx
                        let contract = contracts[tx.toAddress]
                        // TODO: remove print of addresses without name tags
                        if contract?.nameTag == nil || contract?.name == nil {
                            print(tx.toAddress)
                        }
                        if let nameTag = contract?.nameTag, !nameTag.isEmpty {
                            tx.contractName = nameTag
                        } else if let contractName = contract?.name, !contractName.isEmpty {
                            tx.contractName = contractName
                        } else {
                            tx.contractName = tx.toAddress
                        }
                        return tx
                    }
                    self.transactions.append(contentsOf: txs)
                    state = .fetched(txs: self.transactions)
                    isFetching = false
                case .sent:
                    //TODO: Implement me!
                    DispatchQueue.main.async { [weak self] in
                        self?.state = .error(message: "Not yet implemented!")
                    }
                case .received:
                    //TODO: Implement me!
                    DispatchQueue.main.async { [weak self] in
                        self?.state = .error(message: "Not yet implemented!")
                    }
                case .interactions:
                    //TODO: Implement me!
                    DispatchQueue.main.async { [weak self] in
                        self?.state = .error(message: "Not yet implemented!")
                    }
                case .failed:
                    //TODO: Implement me!
                    DispatchQueue.main.async { [weak self] in
                        self?.state = .error(message: "Not yet implemented!")
                    }
                }
            } catch let error {
                //TODO: Error handling / Define error cases and appropriate error messages
                state = .error(message: error.localizedDescription)
            }
        }
    }
    
    func bindTransactionFilter() {
        $filter
            .sink { [weak self] _ in
                self?.fetchTransactions()
            }
            .store(in: &cancellables)
    }
    
    func fetchTransactionsIfNeeded(currentTransaction transaction: TransactionGroup) {
        guard canLoadNextPage(atTransaction: transaction) else { return }
        fetchTransactions()
    }
    
    private func canLoadNextPage(atTransaction transaction: TransactionGroup) -> Bool {
        guard let index: Int = transactions.firstIndex(of: transaction) else { return false }
        let reachedThreshold = Double(index) / Double(transactions.count) > 0.7
        return !isFetching && reachedThreshold
    }
    
    @MainActor
    private func fetchContracts(fromTxs txs: [TransactionGroup]) async {
        var contracts = [Contract]()
        await withTaskGroup(of: Contract?.self) { [weak self] group in
            guard let self = self else { return }
            for tx in txs {
                group.addTask {
                    guard let contractAddress = tx.transactions.first?.to,
                          self.contracts[tx.toAddress] == nil else { return nil }
                    // TODO: Fetch tx input and decode with ABI fetched here
                    // Discuss if we want to fetch tx input and contract details on list or on tx detail screen
                    // If we want to show all details on the list, performance may be laggy because of the numerous fetches
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

struct TransactionViewModel: Identifiable {
    var id: UUID = UUID()
    let hash: String
    let blockNum: String
    let fromAddress: String
    let toAddress: String?
    let value: String
    let erc721TokenId: String?
    let asset: String
    let category: String
}

//extension TransactionViewModel {
//
//    init(tx: AlchemyAssetTransfer) {
//        self.init(
//            hash: tx.hash,
//            blockNum: tx.blockNum.intValue.flatMap(String.init) ?? "",
//            fromAddress: tx.from.address,
//            toAddress: tx.to.address,
//            value: tx.value, // TODO: Handle formatting
//            erc721TokenId: tx.erc721TokenId,
//            asset: tx.asset ?? "",
//            category: tx.category?.rawValue ?? ""
//        )
//    }
//    
//    static var placeholder: TransactionViewModel {
//        .init(
//            hash: "",
//            blockNum: "",
//            fromAddress: "0x225e9b54f41f44f42150b6aaa730da5f2d23faf2",
//            toAddress: "0x225e9b54f41f44f42150b6aaa730da5f2d23faf2",
//            value: "0.0",
//            erc721TokenId: nil,
//            asset: "ETH",
//            category: "external"
//        )
//    }
//}

enum TransactionFilter: Int {
    case all
    case sent
    case received
    case interactions
    case failed
}
