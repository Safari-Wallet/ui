//
//  Contract.swift
//  Wallet (iOS)
//
//  Created by Stefano on 05.12.21.
//

struct Contract {
    let contractAddress: String
    let contractName: String
    let nameTag: String
}

extension Contract: Decodable {
    
    enum CodingKeys : String, CodingKey {
        case contractAddress = "Address"
        case contractName = "NameTagContractDetails"
        case nameTag = "NameTag"
    }
}

struct ContractDetail: Hashable {
    let contractName: String
    let abi: String
}
