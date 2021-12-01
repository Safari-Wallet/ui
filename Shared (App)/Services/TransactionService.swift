//
//  TransactionService.swift
//  Wallet (iOS)
//
//  Created by Stefano on 11.11.21.
//

import MEWwalletKit
import SafariWalletCore

protocol TransactionFetchable {
    func fetchTransactions(network: Network, address: Address, page: Int) async throws -> [TransactionGroup]
}

final class TransactionService: TransactionFetchable {
    
    private let unmarshalClient: UnmarshalClient? = UnmarshalClient(apiKey: ApiKeys.unmarshal)
    
    @MainActor
    func fetchTransactions(network: Network, address: Address, page: Int) async throws -> [TransactionGroup] {

        guard let client = unmarshalClient else { throw TransactionError.networkConnectionFailed }
        async let unmarshalTransactions = client.getTransactions(address: address, page: page)

        var walletTransactions =  [WalletTransaction]()
        walletTransactions.append(contentsOf: try await unmarshalTransactions)
        
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
        
        return Array(hashGroup.values.sorted())
    }
    
}

enum TransactionError: Error {
    case networkConnectionFailed
}

private extension Block {
    static let genesis = Block(rawValue: 0)
}
