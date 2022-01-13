//
//  ZerionClient.swift
//  
//
//  Created by Stefano on 30.12.21.
//

import Foundation
import Network
import MEWwalletKit
import SocketIO

public final class ZerionClient {
    
    private let apiKey: String
    private let socketManager: SocketManager
    private let socketClient: SocketIOClient
    
    private let timeout: Double = 10
    private var connectContinuation: CheckedContinuation<(), Error>?
    private var transactionContinuation: CheckedContinuation<Zerion.Response, Error>?
    
    public init(apiKey: String) {
        self.apiKey = apiKey
        socketManager = SocketManager(
            socketURL: URL(string: "wss://api-v4.zerion.io")!,
            config: [
                .log(false),
                .forceWebsockets(true),
                .connectParams(["api_token": apiKey]),
                .version(.two),
                .secure(true)
            ]
        )
        socketClient = socketManager.socket(forNamespace: "/address")
        listenForConnections()
        listenForTransactions()
    }
    
    private func connectIfNeeded() async throws {
        return try await withCheckedThrowingContinuation { [weak self] continuation in
            guard socketClient.status != .connected else {
                continuation.resume(with: .success(()))
                return
            }
            self?.connectContinuation = continuation
            socketClient.connect(timeoutAfter: timeout) {
                continuation.resume(with: .failure(NoDataError()))
                return
            }
        }
    }
    
    private func listenForConnections() {
        socketClient.on(clientEvent: .connect) { [weak self] data, ack in
            self?.connectContinuation?.resume(with: .success(()))
            self?.connectContinuation = nil
        }
    }
}

// MARK: - Transactions

extension ZerionClient {
    
    /*
     * https://docs.zerion.io/websockets/namespaces/address
     */
    
    /// Returns an array transactions based on the address.
    /// - SeeAlso: [Documentation](https://docs.zerion.io/websockets/namespaces/address)
    /// - Parameters:
    ///   - network: blockchain network.
    ///   - address: in hex string.
    ///   - offset: offset. default is 50. optional
    ///   - limit: number of records to be displayed per page. optional
    /// - Returns: Returns an array transactions based on the address.
    public func getTransactions(network: Network = .ethereum,
                                address: Address,
                                currency: String = "usd", // TODO: Add currency enum
                                offset: Int? = nil,
                                limit: Int? = nil) async throws -> Zerion.Response {
        try await connectIfNeeded()
        
        let items = makeQueryItems(address: address, currency: currency, offset: offset, limit: limit)
        // TODO: add timeout
        socketClient.emit("get", items)
        
        return try await withCheckedThrowingContinuation { [weak self] continuation in
            self?.transactionContinuation = continuation
        }
    }
    
    private func listenForTransactions() {
        socketClient.on("received address transactions") { data, ack in
            do {
                let data = try JSONSerialization.data(withJSONObject: data, options: .fragmentsAllowed)
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                guard let response = try decoder.decode([Zerion.Response].self, from: data).first else {
                    throw NoDataError()
                }
                self.transactionContinuation?.resume(with: .success(response))
            } catch let error {
                self.transactionContinuation?.resume(with: .failure(error))
            }
        }
    }
    
    private func makeQueryItems(address: Address,
                                currency: String,
                                offset: Int?,
                                limit: Int?) -> [String: Any] {
        var items = [String: Any]()
        var payload: [String: Any] = [
            "address": address.address,
            "currency": currency
        ]
        if let offset = offset {
            payload["transactions_offset"] = offset
        }
        if let limit = limit {
            payload["transactions_limit"] = limit
        }
        items["scope"] = ["transactions"]
        items["payload"] = payload
        return items
    }
}
