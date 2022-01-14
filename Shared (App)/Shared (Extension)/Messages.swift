//
//  Messages.swift
//  Wallet
//
//  Created by Jamie Rumbelow on 09/01/2022.
//

import Foundation




// MARK: - Setup

public enum NativeMessageMethod: String, Codable {
    case eth_getAccounts = "eth_getAccounts"
    case eth_getBalance = "eth_getBalance"
    case helloFren = "helloFren"
}

extension NativeMessageMethod {
    func toFrontendMessage(params: Any) -> FrontendMessage {
        var params:
        switch self {
        case .eth_getAccounts:
            params = EthGetAccountsMessageParams()
        case .eth_getBalance:
            params = EthGetBalanceMessageParams()
        case .helloFren:
            params = HelloFrenMessageParams(foo: params["foo"], bar: params["bar"], wagmi: params["wagmi"])
        }
        
        return FrontendMessage(method: self, params: params)
    }
}

struct FrontendMessage<P : Codable> : Codable {
    var method: NativeMessageMethod
    var params: P
}

// MARK: - Messages

// MARK: EthGetAccountsMessageParams

struct EthGetAccountsMessageParams : Codable {}

// MARK: EthGetBalanceMessage

struct EthGetBalanceMessageParams : Codable {}

// MARK: HelloFrenMessage

struct HelloFrenMessageParams : Codable {
    let foo: String
    let bar: Int
    let wagmi: Bool?
}

// MARK: - Access list

public func getFrontendMessageType<P: FrontendMessage>(method: NativeMessageMethod) throws -> P {
    
}

public class FrontendMessages {
    static let map: [NativeMessageMethod: FrontendMessage.Type] = [
        .eth_getBalance: EthGetBalanceMessage.self,
        .eth_getAccounts: EthGetAccountsMessage.self,
        .helloFren: HelloFrenMessage.self
    ]
    
    static func getMessageType<P: FrontendMessage>(method: NativeMessageMethod) throws -> P {
        if map[method] == nil {
            throw WalletError.invalidInput("Unknown type for method '\(method)'")
        }
        return map[method] as P
    }
}
