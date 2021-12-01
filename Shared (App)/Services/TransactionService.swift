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
    private let unmarshalClient: UnmarshalClient? = UnmarshalClient(apiKey: ApiKeys.unmarshal)
    
    @MainActor
    func fetchTransactions(network: Network, address: Address) async throws -> [TransactionGroup] {

        guard let client = unmarshalClient else { throw TransactionError.networkConnectionFailed }
        
        let unmarshalResponse = try await client.getTransactions(address: address, page: currentPage)

        guard currentPage < unmarshalResponse.total_pages else { return [] }
        
        var walletTransactions =  [WalletTransaction]()
        walletTransactions.append(contentsOf: unmarshalResponse.transactions)
        
        var hashGroup = [String: TransactionGroup]()
        for transaction in walletTransactions {
            if var group = hashGroup[transaction.hash] {
                
                group.transactions.append(transaction)
                hashGroup[transaction.hash] = group
            } else {
                let newGroup = TransactionGroup(transactionHash: transaction.hash, transactions: [transaction])
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
