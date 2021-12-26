//
//  TransactionDecoder.swift
//  Wallet
//
//  Created by Stefano on 21.12.21.
//

import Foundation
import MEWwalletKit
import UIKit

protocol TransactionDecodable {
    func decode(input: String, with contract: Contract) -> TransactionInput?
}

struct TransactionDecoder: TransactionDecodable {
    
    func decode(input: String, with contract: Contract) -> TransactionInput? {
        guard let data = contract.abi.data(using: .utf8),
              let abiRecords = try? JSONDecoder().decode([ABI.Record].self, from: data) else {
            return nil
        }
        for record in abiRecords {
            let element = try? record.parse()
            if case .function(let function) = element {
                let signature = function.signature
                let decodedMethodHash = function.methodString
                let data = Data(hex: input)
                guard !data.isEmpty, data.count > 4 else { return nil }
                let methodHash = data[0 ..< 4].dataToHexString()
                if methodHash == decodedMethodHash, let decodedInput = element?.decodeInputData(data) {
                    let parameters = getInputParameters(of: function)
                    let inputData = mapToInputDataFrom(parameters: parameters, input: decodedInput)
                    return TransactionInput(
                        method: Method(
                            name: function.name ?? "",
                            signature: signature,
                            hash: methodHash,
                            inputs: parameters
                        ),
                        inputData: inputData
                    )
                }
            }
        }
        return nil
    }
    
    private func getInputParameters(of function: ABI.Element.Function) -> [InputParameter] {
        function.inputs.map { InputParameter(name: $0.name, type: $0.type) }
    }
    
    private func mapToInputDataFrom(parameters: [InputParameter], input: [String: Any]) -> [InputName: InputData] {
        let inputData = parameters.compactMap { param -> (InputName, InputData)? in
            guard let data = input[param.name] else { return nil }
            return (param.name, InputData(parameter: param, data: data))
        }
        return Dictionary(
            inputData,
            uniquingKeysWith: { (first, _) in first }
        )
    }
}
