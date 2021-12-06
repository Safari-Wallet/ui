//
//  ContractService.swift
//  Wallet (iOS)
//
//  Created by Stefano on 05.12.21.
//

import Foundation
import MEWwalletKit
import SafariWalletCore

protocol ContractFetchable {
    func fetchContractDetails(forAddress: Address) async throws -> ContractDetail?
}

final class ContractService: ContractFetchable {
    
    private let client: EtherscanClient = EtherscanClient(apiKey: ApiKeys.etherscan)
    
    @MainActor
    func fetchContractDetails(forAddress address: Address) async throws -> ContractDetail? {
        let response = try await client.getContractDetails(forAddress: address)
        let contract = ContractDetail(response: response)
        return contract
    }
}

extension ContractDetail {
    
    init?(response: Etherscan.ContractResponse) {
        guard let contract = response.result.first else { return nil }
        self.init(
            contractName: contract.contractName,
            abi: contract.abi
        )
    }
}

struct Contract: Decodable {
    let contractAddress: String
    let contractName: String
}
