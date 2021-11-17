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
    
    private let alchemyClient: AlchemyClient? = AlchemyClient(key: ApiKeys.alchemyMainnet)
    private let covalentClient: CovalentClient? = CovalentClient(apiKey: ApiKeys.covalent)
    private let unmarshalClient: UnmarshalClient? = UnmarshalClient(apiKey: ApiKeys.unmarshal)
    
    @MainActor
    func fetchAllTransactions(chain: String,
                              address: String,
                              currency: String,
                              symbol: String) async throws -> [AlchemyAssetTransfer] {
        guard let client = alchemyClient else { throw TransactionError.networkConnectionFailed }
        let sentTxs = try await client.alchemyAssetTransfers(
            fromBlock: .genesis,
            fromAddress: Address(address: address)
        )
        let receivedTxs = try await client.alchemyAssetTransfers(
            fromBlock: .genesis,
            toAddress: Address(address: address)
        )
        return sentTxs + receivedTxs
    }
    
    @MainActor
    func fetchSentTransactions(chain: String,
                               address: String,
                               currency: String,
                               symbol: String) async throws -> [AlchemyAssetTransfer] {
        guard let client = alchemyClient else { throw TransactionError.networkConnectionFailed }
        let sentTxs = try await client.alchemyAssetTransfers(
            fromBlock: .genesis,
            fromAddress: Address(address: address),
            toAddress: Address(address: address)
        )
        return sentTxs
    }
    
    @MainActor
    func fetchReceivedTransactions(chain: String,
                                   address: String,
                                   currency: String,
                                   symbol: String) async throws -> [AlchemyAssetTransfer] {
        guard let client = alchemyClient else { throw TransactionError.networkConnectionFailed }
        let receivedTxs = try await client.alchemyAssetTransfers(
            fromBlock: .genesis,
            toAddress: Address(address: address)
        )
        return receivedTxs
    }
    
    func fetchTransactions(network: Network, address: Address) async throws -> [WalletTransactionType] {
        async let alchemyOutgoingTransactions = self.alchemyClient!.alchemyAssetTransfers(fromBlock: .genesis,
                                                                                          toBlock: .latest,
                                                                                          fromAddress: address)
        async let alchemyIncomingTransactions = self.alchemyClient!.alchemyAssetTransfers(fromBlock: .genesis,
                                                                                          toBlock: .latest,
                                                                                          toAddress: address)
        async let covalentTransactions = self.covalentClient!.getTransactions(network: .ethereum, address: address)
        async let unmarshalTransactions = self.unmarshalClient!.getTransactions(address: address)

        var walletTransaction =  [WalletTransaction]()
        walletTransaction.append(contentsOf: try await alchemyOutgoingTransactions)
        walletTransaction.append(contentsOf: try await alchemyIncomingTransactions)
        walletTransaction.append(contentsOf: try await covalentTransactions)
        walletTransaction.append(contentsOf: try await unmarshalTransactions)
        return walletTransaction.map({ WalletTransactionType(transaction: $0) })
    }
    
}

enum TransactionError: Error {
    case networkConnectionFailed
}

private extension Block {
    static let genesis = Block(rawValue: 0)
}
