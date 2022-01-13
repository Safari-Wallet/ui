//
//  CovalentClient.swift
//  
//
//  Created by Tassilo von Gerlach on 11/6/21.
//

import Foundation
import Network
import MEWwalletKit

public final class CovalentClient {
    
    private let apiKey: String
    private let urlSession: URLSession
    
    public init(apiKey: String, urlSession: URLSession = .shared) {
        self.apiKey = apiKey
        self.urlSession = urlSession
    }
}

// MARK: - Transactions

extension CovalentClient {
    
    /// Returns an array transactions based on the address.
    /// - Parameters:
    ///   - network: blockchain network.
    ///   - address: in hex string.
    /// - Returns: Returns an array transactions based on the address.
    public func getTransactions(network: Network = .ethereum,
                                address: Address) async throws -> [Covalent.Transaction] {
        let endpoint = try makeEndpointFrom(network: network, address: address)
        let response = try await urlSession.load(endpoint)
        return response.data.items
    }
    
    private func makeEndpointFrom(
        network: Network,
        address: Address
    ) throws -> Endpoint<Covalent.Response<Covalent.GetTransactionsResponseData>> {
        guard let url = URL(string: "https://api.covalenthq.com/v1/\(network.chainID)/address/\(address.address)/transactions_v2/") else { throw InvalidRequestError() }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let query = [
            "key": apiKey,
            "quote-currency": "USD"
        ]
        return Endpoint(
            json: .get,
            url: url,
            query: query,
            decoder: decoder
        )
    }
}
