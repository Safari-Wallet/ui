//
//  EtherscanClient.swift
//  
//
//  Created by Stefano on 04.12.21.
//

import Foundation

public final class EtherscanClient {
    
    private let apiKey: String
    private let urlSession: URLSession
    
    public init(apiKey: String, urlSession: URLSession = .shared) {
        self.apiKey = apiKey
        self.urlSession = urlSession
    }
}

// MARK: - Contracts

extension EtherscanClient {
    
    /// Returns contract details based on the contract request.
    /// - SeeAlso: [Etherscan documentation](https://docs.etherscan.io/api-endpoints/contracts)
    /// - Parameters:
    ///   - address: in hex string.
    /// - Returns: Returns contract details based on the contract request.
    public func getContractDetails(forAddress address: String) async throws -> Etherscan.ContractResponse {
        let endpoint = try makeEndpointFrom(address: address)
        return try await urlSession.load(endpoint)
    }
    
    private func makeEndpointFrom(
        address: String
    ) throws -> Endpoint<Etherscan.ContractResponse> {
        guard let url = URL(string: "https://api.etherscan.io/api/") else { throw InvalidRequestError() }
        let query = [
            "apikey": apiKey,
            "module": "contract",
            "action": "getsourcecode",
            "address": address
        ]
        return Endpoint(
            json: .get,
            url: url,
            query: query
        )
    }
}
