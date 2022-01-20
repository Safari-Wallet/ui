//
//  Messages.swift
//  Wallet
//
//  Created by Jamie Rumbelow on 09/01/2022.
//

import Foundation
import SafariServices
import SafariWalletCore

// MARK: - Setup

enum MessageError: Error {
    case unknownMethod(NativeMessageMethod)
}

struct NativeMessage: Decodable {
    var method: NativeMessageMethod
    var params: NativeMessageParams
}

protocol NativeMessageParams: Codable {
    func execute(with userSettings: UserSettings) async throws -> Any
}

// MARK: - Message parsing

enum NativeMessageMethod: String, Decodable {
    case eth_getAccounts
    case eth_getBalance
    case helloFren
}

extension NativeMessage {
    private enum CodingKeys: CodingKey {
        case method
        case params
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        method = try container.decode(NativeMessageMethod.self, forKey: .method)
        
        switch method {
        case .eth_getAccounts:
            params = try container.decode(eth_getAccountsMessageParams.self, forKey: .params)
        case .eth_getBalance:
            params = try container.decode(eth_getBalanceMessageParams.self, forKey: .params)
        case .helloFren:
            params = try container.decode(helloFrenMessageParams.self, forKey: .params)
        }
    }
}

// MARK: - Runtime

func parseMessageParams(message: [String: Any]) throws -> NativeMessageParams {
    let jsonEncoded = try JSONSerialization.data(withJSONObject: message, options: [])
    let parsedMessage = try JSONDecoder().decode(NativeMessage.self, from: jsonEncoded)
    return parsedMessage.params
}

