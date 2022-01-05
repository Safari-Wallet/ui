//
//  TransactionService.swift
//  Wallet (iOS)
//
//  Created by Stefano on 11.11.21.
//

import MEWwalletKit
import SafariWalletCore

protocol TransactionFetchable {
    func fetchTransactions(network: Network, address: Address) async throws -> [TransactionActivity]
}

final class TransactionService: TransactionFetchable {
    
    private var currentPage = 0
    private let limit = 50
    private let zerionClient = ZerionClient(apiKey: ApiKeys.zerion)
    
    @MainActor
    func fetchTransactions(network: Network, address: Address) async throws -> [TransactionActivity] {
        let zerionResponse = try await zerionClient.getTransactions(address: address, offset: currentPage * limit, limit: limit)
        let transactionActivities = zerionResponse.payload.transactions.map { tx in
            TransactionActivity(tx: tx, meta: zerionResponse.meta)
        }
        currentPage += 1 // TODO: move to view model?
        return transactionActivities
    }
    
}
