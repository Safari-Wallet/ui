//
//  JsonRpcResponse.swift
//  Wallet
//
//  Created by Tassilo von Gerlach on 10/21/21.
//

import Foundation

public struct JsonRpcResponse<Result: Decodable>: Decodable {
   
    public let jsonrpc: String
    public let result: Result?
    public let error: JsonRpcError?
    public let id: Int
   
}
