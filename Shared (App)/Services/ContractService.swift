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
    func name(forAddress address: RawAddress) -> Contract?
    func fetchContractDetails(forAddress: Address) async throws -> ContractDetail?
}

typealias RawAddress = String

final class ContractService: ContractFetchable {
    
    private let client: EtherscanClient = EtherscanClient(apiKey: ApiKeys.etherscan)
    
    /// Address string to contract lookup
    private lazy var contractNameLookup: [RawAddress: Contract] = {
        let decoder = PropertyListDecoder()
        guard let url = Bundle.main.url(forResource: "ContractNameTags", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let contracts = try? decoder.decode([Contract].self, from: data) else { return [:] }
        return Dictionary(uniqueKeysWithValues: contracts.map { ($0.contractAddress, $0) })
    }()
    
    func name(forAddress address: RawAddress) -> Contract? {
        return contractNameLookup[address]
    }
    
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
