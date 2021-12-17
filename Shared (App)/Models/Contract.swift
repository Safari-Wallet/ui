//
//  Contract.swift
//  Wallet (iOS)
//
//  Created by Stefano on 05.12.21.
//

struct Contract {
    let address: String
    let name: String
    let abi: String
    let nameTag: String? // Could be an array of name tags
}

struct ContractInfo {
    let contractAddress: String
    let contractName: String
    let nameTag: String
}

extension ContractInfo: Decodable {
    
    enum CodingKeys : String, CodingKey {
        case contractAddress = "Address"
        case contractName = "NameTagContractDetails"
        case nameTag = "NameTag"
    }
}
