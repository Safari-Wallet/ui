//
//  TransactionInputParser.swift
//  Wallet
//
//  Created by Stefano on 21.12.21.
//

import Foundation

protocol TransactionInputParseable {
    func parse(input: [String: String], methodHash: String, contractAddress: RawAddress) -> String?
}

typealias MethodID = String

final class TransactionInputParser: TransactionInputParseable {
    
    private lazy var methodInfoLookup: [RawAddress: [MethodID: MethodInfo]] = {
        let decoder = PropertyListDecoder()
        
        guard let url = Bundle.main.url(forResource: "MethodInfo", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let methodInfo = try? decoder.decode([MethodInfo].self, from: data) else { return [:] }
        
        let methodInfoDict = methodInfo.reduce([RawAddress: [MethodID: MethodInfo]]()) { partialResult, info in
            var methodInfoDict = partialResult
            if methodInfoDict[info.contractAddress] != nil {
                methodInfoDict[info.contractAddress]?[info.methodId] = info
            } else {
                methodInfoDict[info.contractAddress] = [info.methodId: info]
            }
            return methodInfoDict
        }
        return methodInfoDict
    }()
    
    func parse(input: [String: String], methodHash: String, contractAddress: RawAddress) -> String? {
        guard let methodInfo = methodInfoLookup[contractAddress]?[methodHash] else { return nil }
        let arguments = methodInfo.description.arguments.compactMap { input[$0] }
        return String(format: methodInfo.description.stringFormat, arguments: arguments)
    }
}
