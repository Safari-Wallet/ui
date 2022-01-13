//
//  JsonRpcError.swift
//  Wallet
//
//  Created by Tassilo von Gerlach on 10/21/21.
//

import Foundation

public struct JsonRpcError: Codable, Error {
   
    public let code: Int
    public let message: String
   
}
