//
//  UnmarshalClient.swift
//  
//
//  Created by Tassilo von Gerlach on 11/8/21.
//

import Foundation
import Network
import MEWwalletKit

public final class UnmarshalClient {
    
    private let apiKey: String
    private let urlSession: URLSession
    
    public init(apiKey: String, urlSession: URLSession = .shared) {
        self.apiKey = apiKey
        self.urlSession = urlSession
    }
}

// MARK: - Transactions

extension UnmarshalClient {
    
    /*
     * https://docs.unmarshal.io/unmarshal-apis/token-transactions-api
     */
    
    /// Returns an array transactions based on the address.
    /// - SeeAlso: [Unmarshal documentation](https://docs.unmarshal.io/unmarshal-apis/token-transactions-api)
    /// - Parameters:
    ///   - network: blockchain network.
    ///   - address: in hex string.
    ///   - page: page number. optional
    ///   - pageSize: number of records to be displayed per page. optional
    /// - Returns: Returns an array transactions based on the address.
    public func getTransactions(network: Network = .ethereum,
                                address: Address,
                                page: Int? = nil,
                                pageSize: Int? = nil) async throws -> Unmarshal.TokenTransactionsResponse {
        let endpoint = try makeEndpointFrom(network: network, address: address, page: page, pageSize: pageSize)
        return try await urlSession.load(endpoint)
    }
    
    private func makeEndpointFrom(
        network: Network,
        address: Address,
        page: Int?,
        pageSize: Int?
    ) throws -> Endpoint<Unmarshal.TokenTransactionsResponse> {
        guard let url = URL(string: "https://stg-api.unmarshal.io/v1/\(network.name.lowercased())/address/\(address.address)/transactions") else { throw InvalidRequestError() }
        var query = [
            "auth_key": apiKey
        ]
        if let page = page {
            query["page"] = String(page)
        }
        if let pageSize = pageSize {
            query["pageSize"] = String(pageSize)
        }
        return Endpoint(
            json: .get,
            url: url,
            query: query
        )
    }
}
