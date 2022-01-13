//
//  ProviderAPI.swift
//  
//
//  Created by Ronald Mannak on 11/5/21.
//

import Foundation
import os.log
import MEWwalletKit

// Implementation of https://docs.metamask.io/guide/ethereum-provider.html and https://docs.metamask.io/guide/rpc-api.html
public struct ProviderAPI {
    
    public let delegate: SafariWalletCoreDelegate
    let logger = Logger()
    
    public init(delegate: SafariWalletCoreDelegate) {
        self.delegate = delegate
    }
    
    public func parseMessage(method: String, params: Any?) async throws -> Any {

        guard let client = delegate.client() else {
            logger.critical("ProviderAPI SafariWebExtensionHandler: No delegate client")
            throw WalletCoreError.noClient
        }
        
        switch method {
            
        // MARK: - Provider API
        /*
        case "maxRetries":
            // https://docs.alchemy.com/alchemy/documentation/alchemy-web3#maxretries
            guard let amount = params as? Int else {
                return client.maxRetries
            }
            client.maxRetries = amount
            return []
            
        case "retryInterval":
            // https://docs.alchemy.com/alchemy/documentation/alchemy-web3#retryinterval
            guard let amount = params as? Int else {
                return client.retryInterval
            }
            client.retryInterval = amount
            return []
        
        case "retryJitter":
            // https://docs.alchemy.com/alchemy/documentation/alchemy-web3#retryjitter
            guard let amount = params as? Int else {
                return client.retryJitter
            }
            client.retryJitter = amount
            return []
         */
            
        case "isConnected":
            return client.isConnected
        
        case "request":
            throw WalletCoreError.notImplemented("request")
            
        // MARK: - JSONRPC API
        case "eth_accounts", "eth_requestAccounts", "eth_getAccounts":
            if let address = delegate.addresses()?.first {
                logger.critical("ProviderAPI SafariWebExtensionHandler: fetching accounts: \(address, privacy: .public)")
            } else {
                logger.critical("ProviderAPI SafariWebExtensionHandler: adresses returned nil")
            }
            
            // https://eth.wiki/json-rpc/API#eth_accounts
            return delegate.addresses() ?? []
                        
            
        // Uncomment one of the eth_call cases to test
            
//        case "eth_call":
//            // V1. This version expects a complete JSON-RPC object to be passed as the params value, like: {"jsonrpc":"2.0","method":"eth_call","params":[<call>, "latest"],"id":1}
//            // Returns mock Data
//            guard let params = params  else { throw WalletCoreError.noParameters }
//            let data = try JSONSerialization.data(withJSONObject: params)
//            return try await client.ethCallMock(data: data)
//
//        case "eth_call":
//            // V2. Same as above, but returns real data from Alchemy (account needs to be funded to call!)
//            guard let params, let data = try JSONSerialization.data(withJSONObject: params) = params else { throw WalletCoreError.noParameters }
//            return try await client.ethCall(data: data)
            
        case "eth_call":
            // V3. Same as V1 but returns a string
            guard let params = params else { throw WalletCoreError.noParameters }
            let data = try JSONSerialization.data(withJSONObject: params)
            let result = try await client.ethCallMock(data: data)
            return String(data: result, encoding: .utf8) ?? "Error encoding result"
            
        /* Ignore this code.
            // This version expects ...
            // https://eth.wiki/json-rpc/API#eth_call
            guard let params, let data = try JSONSerialization.data(withJSONObject: params) = params else { throw WalletCoreError.noParameters }
            
            
            guard let params = params as? [Any], params.count == 2, let callDict = params[0] as? [String: Any], let blockString = params[1] as? String else { throw WalletCoreError.invalidParams}

            let callData = try JSONSerialization.data(withJSONObject: callDict)
            let call = JSONEncoder().encode(<#T##value: Encodable##Encodable#>)
            let block = Block(rawValue: blockString)
            
            let call = Call(from: <#T##Address?#>, to: <#T##Address#>, gas: <#T##Int?#>, gasPrice: <#T##Wei?#>, value: <#T##Wei?#>, data: <#T##String?#>)
            
//            return try await client.ethCall(params: params ?? [])
            return "" */

        case "eth_getBalance":
            // https://eth.wiki/json-rpc/API#eth_getbalance
            guard let params = params as? [String], params.count == 2 else {
                throw WalletCoreError.invalidParams
            }
            let result = try await client.ethGetBalance(address: params[0], blockNumber: Block(rawValue: params[1]))
            return result.hexString
            
        case "eth_sendTransaction":
            // https://eth.wiki/json-rpc/API#eth_sendtransaction
            // FIXME: Returns mock result
            return "0xe670ec64341771606e55d6b4ca35a1a6b75ee3d5145a99d05921026d1527331"
            
        case "eth_sign":
            // https://eth.wiki/json-rpc/API#eth_sign
            guard let params = params as? [String], params.count >= 2 else {
                throw WalletCoreError.invalidParams
            }
            let address = params[0]
            let message = params[1]
            let password: String?
            if params.count >= 3 {
                password = params[2]
            } else {
                password = nil
            }
            let account = try await delegate.account(address: address, password: password)
            return try account.sign(hexString: message)
                        
        default:
            throw WalletCoreError.unknownMethod(method)
        }
    }
}
