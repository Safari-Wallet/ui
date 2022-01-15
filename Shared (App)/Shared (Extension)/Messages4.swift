//
//  Messages4.swift
//  Wallet
//
//  Created by Ronald Mannak on 1/14/22.
//

import Foundation
import SafariWalletCore
import MEWwalletKit

func parseMessage4() async throws -> Any? {
    
    let message: [String: Any] = [
        "method": "helloFren",
        "params": [
            "foo": "bar",
            "bar": 42,
            "wagmi": true
        ]
    ]
    
    let jsonEncoded = try JSONSerialization.data(withJSONObject: message, options: [])
    let messageObj = try JSONDecoder().decode(NativeMessage4.self, from: jsonEncoded)
    return try await messageObj.params?.execute()
}

// MARK: - Message

enum NativeMessageMethod4: String, Decodable {
    case eth_getAccounts
    case eth_getBalance
    case helloFren
}

struct NativeMessage4: Decodable {
    var method: NativeMessageMethod4
    var params: NativeMessageParams4?
}

extension NativeMessage4 {

    private enum CodingKeys: CodingKey {
        case method
        case params
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        method = try container.decode(NativeMessageMethod4.self, forKey: .method)

        switch method {
        case .eth_getAccounts:
            assertionFailure()
        case .eth_getBalance:
            assertionFailure()
        case .helloFren:
            params = try container.decode(HelloFrenMessageParams4.self, forKey: .params)
        default:
            assertionFailure()
        }
    }
}

// MARK: -- Params

protocol NativeMessageParams4: Decodable {
    func execute() async throws -> Any?
//    func execute() async throws -> NativeMessageResponse? optional: fancy return type
}

struct HelloFrenMessageParams4: NativeMessageParams4 {
    
    let foo: String
    let bar: Int
    let wagmi: Bool?

    func execute() async throws -> Any? {
        // do something here
        return nil
    }
}

struct eth_getBalanceMessageParams4: NativeMessageParams4 {
    
    let address: Address
    let block: Block
    
    func execute() async throws -> Any? {
        // do something here
        return nil
    }
    
    private enum CodingKeys: CodingKey {
        case address
        case block
    }
    
    // Fancy decoder with default values
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        address = try container.decode(Address.self, forKey: .address)
        if let block = try container.decodeIfPresent(Block.self, forKey: .block) {
            self.block = block
        } else {
            self.block = .latest
        }
    }
}
