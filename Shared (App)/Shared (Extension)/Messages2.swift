//
//  Messages2.swift
//  Wallet
//
//  Created by Ronald Mannak on 1/14/22.
//

import Foundation


enum NativeMessageType: String, Decodable {
    case eth_getAccounts
    case eth_getBalance
    case helloFren
}

protocol NativeMessage<T, P>: Decodable {
    var message: NativeMessageType { get }
    var params: P? { get }
    
    func execute() async throws -> NativeMessageResponse?
}

// custom JSON decoding with generic?

struct HelloFrenMessageParams2 : NativeMessage {
    let foo: String
    let bar: Int
    let wagmi: Bool?
        

    func execute() -> Any? {
        return nil
    }
}

struct NativeMessageResponse {
    // ...
}
