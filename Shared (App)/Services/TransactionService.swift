//
//  TransactionService.swift
//  Wallet (iOS)
//
//  Created by Stefano on 11.11.21.
//

import MEWwalletKit
import SafariWalletCore

protocol TransactionFetchable {
    func fetchTransactions(network: Network, address: Address) async throws -> [TransactionGroup]
}

final class TransactionService: TransactionFetchable {
    
    private var currentPage = 1
    private let offset = 20
    private let unmarshalClient: UnmarshalClient = UnmarshalClient(apiKey: ApiKeys.unmarshal)
    private let etherscanClient: EtherscanClient = EtherscanClient(apiKey: ApiKeys.etherscan)
    var etherscanDict: [String : Etherscan.Transaction] = [:]
    
    @MainActor
    func fetchTransactions(network: Network, address: Address) async throws -> [TransactionGroup] {
        let unmarshalResponse = try await unmarshalClient.getTransactions(address: address, page: currentPage, pageSize: offset)
        let etherscanResponse = try await etherscanClient.getTransactions(address: address.address, page: currentPage, offset: offset + 20)
        let etherscanTransactionsDict = Dictionary(
            uniqueKeysWithValues: etherscanResponse.result.map { ($0.hash, $0) }
        )
        etherscanDict = etherscanDict.merging(etherscanTransactionsDict)  { (_, new) in new }

        guard currentPage < unmarshalResponse.total_pages else { return [] }
        
        // TODO: Replace TransactionGroup
        var walletTransactions = [WalletTransaction]()
        walletTransactions.append(contentsOf: unmarshalResponse.transactions)
        
        var hashGroup = [String: TransactionGroup]()
        for transaction in walletTransactions {
            if var group = hashGroup[transaction.hash] {
                group.transactions.append(transaction)
                hashGroup[transaction.hash] = group
            } else {
                var newGroup = TransactionGroup(transactionHash: transaction.hash, transactions: [transaction])
                newGroup.inputData = etherscanDict[newGroup.transactionHash]?.input
                hashGroup[transaction.hash] = newGroup
            }
        }
        currentPage += 1
        return Array(hashGroup.values.sorted())
    }
    
}

enum TransactionError: Error {
    case networkConnectionFailed
}

private extension Block {
    static let genesis = Block(rawValue: 0)
}
