//
//  TransactionInput.swift
//  Wallet
//
//  Created by Stefano on 17.12.21.
//

struct TransactionInput {
    let methodName: String
    let methodSignature: String
    let methodHash: String
    let inputs: [String: Any]
}
