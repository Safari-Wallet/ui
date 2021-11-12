//
//  TransactionService.swift
//  Wallet (iOS)
//
//  Created by Stefano on 11.11.21.
//

import MEWwalletKit
import SafariWalletCore

protocol TransactionFetchable {
    func fetchAllTransactions(
        chain: String,
        address: String,
        currency: String,
        symbol: String
    ) async throws -> [AlchemyAssetTransfer] // TODO: Might be replaced with a general Transaction model (Tassi)
    
    func fetchSentTransactions(
        chain: String,
        address: String,
        currency: String,
        symbol: String
    ) async throws -> [AlchemyAssetTransfer]
    
    func fetchReceivedTransactions(
        chain: String,
        address: String,
        currency: String,
        symbol: String
    ) async throws -> [AlchemyAssetTransfer]
}

final class TransactionService: TransactionFetchable {
    
    private let client: AlchemyClient? = AlchemyClient(key: alchemyMainnetKey)
    
    @MainActor
    func fetchAllTransactions(chain: String,
                           address: String,
                           currency: String,
                           symbol: String) async throws -> [AlchemyAssetTransfer] {
        guard let client = client else { throw TransactionError.networkConnectionFailed }
        let sentTxs = try await client.alchemyAssetTransfers(fromBlock: Block(rawValue: 0), fromAddress: Address(address: address))
        let receivedTxs = try await client.alchemyAssetTransfers(fromBlock: Block(rawValue: 0), toAddress: Address(address: address))
        return sentTxs + receivedTxs
    }
    
    @MainActor
    func fetchSentTransactions(chain: String,
                               address: String,
                               currency: String,
                               symbol: String) async throws -> [AlchemyAssetTransfer] {
        guard let client = client else { throw TransactionError.networkConnectionFailed }
        let sentTxs = try await client.alchemyAssetTransfers(fromBlock: Block(rawValue: 0), fromAddress: Address(address: address))
        return sentTxs
    }
    
    @MainActor
    func fetchReceivedTransactions(chain: String,
                                   address: String,
                                   currency: String,
                                   symbol: String) async throws -> [AlchemyAssetTransfer] {
        guard let client = client else { throw TransactionError.networkConnectionFailed }
        let receivedTxs = try await client.alchemyAssetTransfers(fromBlock: Block(rawValue: 0), toAddress: Address(address: address))
        return receivedTxs
    }
}

enum TransactionError: Error {
    case networkConnectionFailed
}
