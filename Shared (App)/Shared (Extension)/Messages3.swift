//
//  Message3.swift
//  Wallet
//
//  Created by Ronald Mannak on 1/14/22.
//

import Foundation
import SafariWalletCore

enum NativeMessageMethod3 {
    case eth_getAccounts
    case eth_getBalance
    case helloFren(params: HelloFrenMessageParams3)

    func execute() async throws -> Any? {
        //
        // Problem: we can't force associated values to conform NativeMessageParams3 protocol
        // Can we use @dynamicCallable here?
    }
}

extension NativeMessageMethod3: Decodable {
    
    private enum CodingKeys: CodingKey {
        case method
        case params
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let method = try container.decode(String.self, forKey: .method)
         
        switch method {
        case "eth_getAccounts":
            assertionFailure()
        case "eth_getBalance":
            assertionFailure()
        case "helloFren":
            let params = try container.decode(HelloFrenMessageParams3.self, forKey: .params)
            self = .helloFren(params: params)
        default:
            assertionFailure()
        }
    }
}

// custom JSON decoding with generic?

protocol NativeMessageParams3: Decodable {
    func execute() async throws -> Any?
}

struct HelloFrenMessageParams3: NativeMessageParams3 {
    
    let foo: String
    let bar: Int
    let wagmi: Bool?

    func execute() async throws -> Any? { // NativeMessageResponse?
        return nil
    }
}
