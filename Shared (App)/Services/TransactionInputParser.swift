//
//  TransactionInputParser.swift
//  Wallet
//
//  Created by Stefano on 21.12.21.
//

import BigInt
import Foundation
import MEWwalletKit

protocol TransactionInputParseable {
    func parse(input: [String: String], methodHash: String, contractAddress: RawAddress) -> String?
    func parseToStringValues(input: TransactionInput) -> [InputName: String]
}

typealias MethodID = String

final class TransactionInputParser: TransactionInputParseable {
    
    private lazy var methodInfoLookup: [RawAddress: [MethodID: MethodInfo]] = {
        let decoder = PropertyListDecoder()
        
        guard let url = Bundle.main.url(forResource: "MethodInfo", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let methodInfo = try? decoder.decode([MethodInfo].self, from: data) else { return [:] }
        
        return methodInfo.reduce([RawAddress: [MethodID: MethodInfo]]()) { partialResult, info in
            var methodInfo = partialResult
            if methodInfo[info.contractAddress] != nil {
                methodInfo[info.contractAddress]?[info.methodId] = info
            } else {
                methodInfo[info.contractAddress] = [info.methodId: info]
            }
            return methodInfo
        }
    }()
    
    func parse(input: [String: String], methodHash: String, contractAddress: RawAddress) -> String? {
        guard let methodInfo = methodInfoLookup[contractAddress]?[methodHash] else { return nil }
        let arguments = methodInfo.description.arguments.compactMap { input[$0] }
        return String(format: methodInfo.description.stringFormat, arguments: arguments)
    }
    
    func parseToStringValues(input: TransactionInput) -> [InputName: String] {
        input.inputData.reduce([InputName: String]()) { partialResult, input in
            var stringValues = partialResult
            stringValues[input.key] = convertRawValueToString(inputData: input.value)
            return stringValues
        }
    }
    
    private func convertRawValueToString(inputData: InputData) -> String? {
        switch inputData.parameter.type {
        case .uint:
            return (inputData.data as? BigUInt).flatMap(String.init)
        case .int:
            return (inputData.data as? BigInt).flatMap(String.init)
        case .address:
            return (inputData.data as? Address).flatMap { $0.address }
        case .function:
            return "n/a"
        case .bool:
            return (inputData.data as? Bool).flatMap(String.init)
        case .bytes, .dynamicBytes:
            return ABIEncoder.convertToData(inputData.data as AnyObject)?.toHexString()
        case .string:
            return inputData.data as? String
        case .array:
            return "n/a"
        case .tuple:
            return "n/a"
        }
    }
}
