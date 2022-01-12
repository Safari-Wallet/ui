//
//  JsonRpcRequest.swift
//  Wallet
//
//  Created by Tassilo von Gerlach on 10/21/21.
//

import Foundation

public struct JsonRpcRequest<P: Encodable>: Encodable {
   
    public let jsonrpc: String
    public let method: String
    public let params: P?
    public let id: Int
   
    public init(method: String, params: P? = nil, id: Int = 1) {
        self.jsonrpc = "2.0"
        self.method = method
        self.params = params
        self.id = id
    }
   
}
