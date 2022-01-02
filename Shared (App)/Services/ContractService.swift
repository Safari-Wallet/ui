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
    func name(forAddress address: RawAddress) -> ContractInfo?
    func fetchContractDetails(forAddress: Address) async throws -> Contract?
}

typealias RawAddress = String

final class ContractService: ContractFetchable {
    
    private let client: EtherscanClient = EtherscanClient(apiKey: ApiKeys.etherscan)
    
    /// Address string to contract lookup
    private lazy var contractNameLookup: [RawAddress: ContractInfo] = {
        let decoder = PropertyListDecoder()
        guard let url = Bundle.main.url(forResource: "ContractInfo", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let contracts = try? decoder.decode([ContractInfo].self, from: data) else { return [:] }
        return Dictionary(uniqueKeysWithValues: contracts.map { ($0.contractAddress, $0) })
    }()
    
    func name(forAddress address: RawAddress) -> ContractInfo? {
        return contractNameLookup[address]
    }
    
    func fetchContractDetails(forAddress address: Address) async throws -> Contract? {
        // TODO: fetch contract details (ABI & Contract name)
//        let response = try await client.getContractDetails(forAddress: address)
//        guard let contractDetails = response.result.first else { return nil }
        guard let contractInfo = name(forAddress: address.address) else { return nil }
        let contract = Contract(
            address: address.address,
            name: "", //contractDetails.contractName,
            abi: "", //contractDetails.abi,
            nameTag: contractInfo.nameTag
        )
        return contract
    }
}
