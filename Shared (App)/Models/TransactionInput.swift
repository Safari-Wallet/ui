//
//  TransactionInput.swift
//  Wallet
//
//  Created by Stefano on 17.12.21.
//

import MEWwalletKit

typealias InputName = String

struct TransactionInput {
    let method: Method
    let inputData: [InputName: InputData]
}

struct Method {
    let name: String
    let signature: String
    let hash: String
    let inputs: [InputParameter]
}

struct InputParameter {
    let name: InputName
    let type: ABI.Element.ParameterType
}

struct InputData {
    let parameter: InputParameter
    let data: Any
}
