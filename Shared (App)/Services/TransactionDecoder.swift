//
//  TransactionDecoder.swift
//  Wallet
//
//  Created by Stefano on 21.12.21.
//

import Foundation
import MEWwalletKit

protocol TransactionDecodable {
    func decodeInput(_ txInput: String, with contract: Contract) -> TransactionInput?
}

struct TransactionDecoder: TransactionDecodable {
    
    func decodeInput(_ txInput: String, with contract: Contract) -> TransactionInput? {
        guard let data = contract.abi.data(using: .utf8),
              let abiRecords = try? JSONDecoder().decode([ABI.Record].self, from: data) else {
            return nil
        }
        for record in abiRecords {
            let element = try? record.parse()
            if case .function(let function) = element {
                let signature = function.signature
                let decodedMethodHash = function.methodString
                let data = Data(hex: txInput)
                guard !data.isEmpty else { return nil }
                let methodHash = data[0 ..< 4].dataToHexString()
                if methodHash == decodedMethodHash, let decodedInput = element?.decodeInputData(data) {
                    return TransactionInput(
                        methodName: signature,
                        methodHash: methodHash,
                        inputs: decodedInput
                    )
                }
            }
        }
        return nil
    }
}

