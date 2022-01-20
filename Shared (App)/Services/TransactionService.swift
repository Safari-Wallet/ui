//
//  TransactionService.swift
//  Wallet (iOS)
//
//  Created by Stefano on 11.11.21.
//

import MEWwalletKit
import SafariWalletCore

protocol TransactionFetchable {
    func fetchTransactions(
        network: Network,
        address: Address,
        offset: Int,
        limit: Int
    ) async throws -> [TransactionActivity]
}

final class TransactionService: TransactionFetchable {
    
    private let zerionClient = ZerionClient(apiKey: ApiKeys.zerion)
    
    @MainActor
    func fetchTransactions(
        network: Network,
        address: Address,
        offset: Int,
        limit: Int
    ) async throws -> [TransactionActivity] {
        let zerionResponse = try await zerionClient.getTransactions(network: network, address: address, offset: offset, limit: limit)
        let transactionActivities = zerionResponse.payload.transactions.map { tx in
            TransactionActivity(tx: tx, meta: zerionResponse.meta)
        }
        return transactionActivities
    }

}
