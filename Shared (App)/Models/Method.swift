//
//  Method.swift
//  Wallet
//
//  Created by Stefano on 21.12.21.
//

import Foundation

struct MethodInfo {
    let contractAddress: String
    let methodId: String
    let description: MethodDescription
}

struct MethodDescription {
    let stringFormat: String
    let arguments: [String]
}

extension MethodInfo: Decodable {
    
    enum CodingKeys : String, CodingKey {
        case contractAddress = "Address"
        case methodId = "MethodId"
        case description = "Description"
    }
}

extension MethodDescription: Decodable {
    
    enum CodingKeys : String, CodingKey {
        case stringFormat = "StringFormat"
        case arguments = "Arguments"
    }
}
