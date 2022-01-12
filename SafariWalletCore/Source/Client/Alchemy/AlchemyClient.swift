//
//  AlchemyClient.swift
//  Wallet
//
//  Created by Ronald Mannak on 10/24/21.
//

import Foundation
import MEWwalletKit
import BigInt

// https://dashboard.alchemyapi.io/composer
public final class AlchemyClient: EthereumClient {
    
    /// The number of times the client will attempt to resend a rate limited request before giving up. Default: 3.
    /// See https://docs.alchemy.com/alchemy/documentation/alchemy-web3#maxretries
    var maxRetries = 3
    
    /// The minimum time waited between consecutive retries, in milliseconds. Default: 1000.
    /// See https://docs.alchemy.com/alchemy/documentation/alchemy-web3#retryinterval
    var retryInterval = 1000
        
    /// A random amount of time is added to the retry delay to help avoid additional rate errors caused by too many concurrent connections,
    /// chosen as a number of milliseconds between 0 and this value. Default: 250.
    /// See https://docs.alchemy.com/alchemy/documentation/alchemy-web3#retryjitter
    var retryJitter = 250
        
    public init?(network: Network = .ethereum, key: String) {
        super.init(network: network, provider: .alchemy(key: key))
    }
}

// MARK: - Transfer API
extension AlchemyClient {
    
    /// Returns an array of asset transfers based on the specified parameters.
    /// - SeeAlso: [Alchemy documentation](https://docs.alchemy.com/alchemy/documentation/enhanced-apis/transfers-api#alchemy_getassettransfers)
    /// - Important: **alchemy_getAssetTransfers is currently only available on Mainnet.**
    /// - Parameters:
    ///   - fromBlock: in hex string or "latest". optional (default to latest)
    ///   - toBlock:  in hex string or "latest". optional (default to latest)
    ///   - fromAddress: in hex string. optional
    ///   - toAddress:  in hex string. optional.
    ///   - contractAddresses:  list of hex strings. optional.
    ///   - transferCategory: list of any combination of external, token. optional, if blank, would include both.
    ///   - excludeZeroValue:  aBoolean . optional (default true)
    ///   - maxCount: max number of results to return per call. optional (default 1000)
    ///   - pageKey: for pagination. optional
    /// - Returns: Returns an array of asset transfers based on the specified paramaters.
    public func alchemyAssetTransfers(fromBlock: Block = .latest,
                                      toBlock: Block = .latest,
                                      fromAddress: Address? = nil,
                                      toAddress: Address? = nil,
                                      contractAddresses: [Address]? = nil,
                                      transferCategory: AlchemyAssetTransferCategory = .all,
                                      excludeZeroValue: Bool = true,
                                      maxCount: Int? = nil,
                                      pageKey: Int? = nil) async throws -> [AlchemyAssetTransfer] {
        
        enum TransferCategory: String, Encodable {
            case external
            case `internal`
            case token
        }
        
        struct CallParams: Encodable {
            let fromBlock: Block? // in hex string or "latest". optional (default to latest)
            let toBlock: Block? //in hex string or "latest". optional (default to latest)
            let fromAddress: Address? // in hex string. optional
            let toAddress: Address? // in hex string. optional.
            let contractAddresses: [Address]? // list of hex strings. optional.
            let category: String? // list of any combination of external, token. optional, if blank, would include both.
            let excludeZeroValue: Bool // aBoolean . optional (default true)
            let maxCount: String? // max number of results to return per call. optional (default 1000)
            let pageKey: String? // for pagination. optional
        }
        
        let params = CallParams(fromBlock: fromBlock,
                                toBlock: toBlock,
                                fromAddress: fromAddress,
                                toAddress: toAddress,
                                contractAddresses: contractAddresses,
                                category: (transferCategory == .all ? nil : transferCategory.rawValue),
                                excludeZeroValue: excludeZeroValue,
                                maxCount: maxCount?.hexString,
                                pageKey: pageKey?.hexString)
        let response = try await jsonRpcClient.makeRequest(method: "alchemy_getAssetTransfers", params: [params], resultType: AlchemyAssetTransfers.self)
        return response.transfers
    }
}

// MARK: - Block API
extension AlchemyClient {
    
    /// Get receipts from all transactions from particular block, instead of fetching the receipts one-by-one.
    /// - SeeAlso: https://docs.alchemy.com/alchemy/documentation/enhanced-apis/block-api-beta#parity_getblockreceipts
    /// - Parameters:
    ///     - Quantity or Tag - integer of a block number, or the string 'earliest', 'latest' or 'pending', as in the default block parameter.
    /// - Returns:
    ///     - The list of all the transaction’s receipts of the given block
//    public func parityBlockReceipts(block: EthereumBlock) async throws -> [TransactionReceipt] {
//        return try await jsonRpcClient.makeRequest(method: "parity_getBlockReceipts", params: [block], resultType: [TransactionReceipt].self)
//    }
}


extension AlchemyClient {
    
    
    /// Returns a suggestion for a max priority fee for dynamic fee transactions in Wei.
    /// Returns a quick estimate for maxPriorityFeePerGas in EIP 1559 transactions. Rather than using feeHistory and making a calculation yourself you can just use this method to get a quick estimate. Note: this is a geth-only method, but Alchemy handles that for you behind the scenes.
    /// # Reference
    /// [Alchemy documentation](https://docs.alchemy.com/alchemy/documentation/alchemy-web3/enhanced-web3-api#web-3-eth-getmaxpriorityfeepergas)
    /// - SeeAlso:
    /// [Alchemy documentation](https://docs.alchemy.com/alchemy/documentation/alchemy-web3/enhanced-web3-api#web-3-eth-getmaxpriorityfeepergas)
    /// - Returns: Az BigInt, which is the maxPriorityFeePerGas suggestion. You can plug this directly into your transaction field.
    public func maxPriorityFeePerGas() async throws -> Wei {
        let gasHex = try await jsonRpcClient.makeRequest(method: "eth_maxPriorityFeePerGas", resultType: String.self)
        guard let gas = Wei(hexString: gasHex) else {
            throw WalletCoreError.unexpectedResponse(gasHex)
        }
        return gas
    }
    
    // MARK: - Alchemy Token API
    
    /// <#Description#>
    /// - Parameters:
    ///   - tokenContract: <#tokenContract description#>
    ///   - owner: <#owner description#>
    ///   - spender: <#spender description#>
    /// - Returns: <#description#>
    public func alchemyTokenAllowance(tokenContract: Address,
                                      owner: Address,
                                      spender: Address) async throws -> Wei {
        let params = [
            "contract": tokenContract.address,
            "owner": owner.address,
            "spender": spender.address
        ]
        let response = try await jsonRpcClient.makeRequest(method: "alchemy_getTokenAllowance", params: [params], resultType: String.self)
        guard let allowance = Wei(response) else {
            throw WalletCoreError.unexpectedResponse(response)
        }
        return allowance
    }
   
}
