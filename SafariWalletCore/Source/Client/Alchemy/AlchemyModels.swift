//
//  AlchemyModels.swift
//  Wallet
//
//  Created by Ronald Mannak on 8/27/21.
//

import Foundation
import BigInt
import MEWwalletKit

public struct AlchemyTokenBalances: Equatable, Codable {
    public let address: Address
    public let tokenBalances: [AlchemyTokenBalance]
}

public struct AlchemyTokenBalance {
    public let contractAddress: Address
    public let tokenBalance: BigUInt?
    public let error: String? // Error?
}

extension AlchemyTokenBalance: Codable {
    
    enum CodingKeys : String, CodingKey {
        case contractAddress
        case tokenBalance
        case error
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.contractAddress = try container.decode(Address.self, forKey: .contractAddress)

        let decodeHexUInt = { (key: CodingKeys) -> BigUInt? in
            return (try? container.decode(String.self, forKey: key)).flatMap { BigUInt(hex: $0)}
        }
        
        self.tokenBalance = decodeHexUInt(.tokenBalance)
//        if let tokenBalance = decodeHexUInt(.tokenBalance) {
//            self.tokenBalance = tokenBalance
//        } else {
//            self.tokenBalance = BigUInt(0)
//        }
        self.error = try? container.decode(String.self, forKey: .error)
    }
}

extension AlchemyTokenBalance: Equatable {
    public static func == (lhs: AlchemyTokenBalance, rhs: AlchemyTokenBalance) -> Bool {
        return lhs.contractAddress == rhs.contractAddress
    }
}


/// https://docs.alchemy.com/alchemy/documentation/alchemy-web3/enhanced-web3-api#returns-2
public struct AlchemyTokenMetadata: Codable {
    public let name: String
    public let symbol: String
    public let decimals: Int
    public let logo: URL?

    public static func == (lhs: AlchemyTokenMetadata, rhs: AlchemyTokenMetadata) -> Bool {
        return lhs.name == rhs.name && lhs.symbol == rhs.symbol && lhs.decimals == rhs.decimals
    }
}

public enum AlchemyAssetTransferCategory: String, Codable {
    case external = "external"
    case internalCategory = "internal"
    case token = "token"
    case all = "all"
}

public struct AlchemyRawContract: Codable {
    public let value: String?
    public let address: Address?
    public let decimal: String?
}

public struct AlchemyAssetTransfer {
    public let blockNum: Block
    public let hash: String
    public let from: Address
    public let to: Address?
    public let value: Float?
    public let erc721TokenId: String?
    public let asset: String?
    public let category: AlchemyAssetTransferCategory?
    public let rawContract: AlchemyRawContract?
}


//THe purpose of this extension is to maintain the memberwise initlizer
//https://sarunw.com/posts/how-to-preserve-memberwise-initializer/
//Unfortuatley this only works in frameworks
extension AlchemyAssetTransfer: Codable {
}

public struct AlchemyAssetTransfers: Codable {
    public let transfers: [AlchemyAssetTransfer]
}

public struct FeeHistoryResponse: Codable {
    public let oldestBlock: Block
    public let reward: [[String]] //[BigUInt]
    public let baseFeePerGas: [String] //[BigUInt]
    public let gasUsedRatio: [Float]
}

/*
 public struct TransactionReceipt {
    let blockHash: String
    let blockNumber: Int
    let contractAddress: Address?
    let cumulativeGasUsed: BigInt
    let effectiveGasPrice: Wei
    let from: Address
    let gasUsed: BigInt
    let logs: [Log]?
    let logsBloom: String?
    let root: String?
    let status: Int
    let to: Address
    let transactionHash: String
}

 public extension TransactionReceipt: Decodable {

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        // decode hex Int and BigInt
        guard let blockNumber = try Int(hex: values.decode(String.self, forKey: .blockNumber)),
              let cumulativeGasUsed = try BigInt(hex: values.decode(String.self, forKey: .cumulativeGasUsed)),
              let effectiveGasPrice = try Wei(hex: values.decode(String.self, forKey: .effectiveGasPrice)),
              let gasUsed = try Wei(hex: values.decode(String.self, forKey: .gasUsed)),
              let status = try Int(hex: values.decode(String.self, forKey: .status))
        else {
            throw JsonRpcClient.NetworkError.decodingError
        }
        
        blockHash = try values.decode(String.self, forKey: .blockHash)
        self.blockNumber = blockNumber
        contractAddress = try values.decode(Address.self, forKey: .contractAddress)
        self.cumulativeGasUsed = cumulativeGasUsed
        self.effectiveGasPrice = effectiveGasPrice
        self.from =  try values.decode(Address.self, forKey: .from)
        self.gasUsed = gasUsed
        if let logs = try? values.decode([Log].self, forKey: .logs) {
            self.logs = logs
        } else {
            self.logs = nil
        }
        logsBloom = try values.decode(String.self, forKey: .logsBloom)
        root = try values.decode(String.self, forKey: .logsBloom)
        
        //    let status: Int
        //    let to: Address
        //    let transactionHash: String
    }
    
    enum CodingKeys: String, CodingKey {
        case blockHash
        case blockNumber
        case contractAddress
        case cumulativeGasUsed
        case effectiveGasPrice
        case from
        case gasUsed
        case logs
        case logsBloom
        case root
        case status
        case to
        case transactionHash
    }
} */
//
//let values = try decoder.container(keyedBy: CodingKeys.self)
//      latitude = try values.decode(Double.self, forKey: .latitude)
//      longitude = try values.decode(Double.self, forKey: .longitude)
//
//      let additionalInfo = try values.nestedContainer(keyedBy: AdditionalInfoKeys.self, forKey: .additionalInfo)
//      elevation = try additionalInfo.decode(Double.self, forKey: .elevation)

    /*
     {"blockHash": "0xb1bafee9dceb78e91ba7fdf65abd75daccc4e2083dce83b425c1fcb427600ab9", "blockNumber": "0x8d2b29", "contractAddress": null, "cumulativeGasUsed": "0x94960b", "effectiveGasPrice": "0x12a05f200", "from": "0x73595076f9e30106e1908ed735965ef727ccb64c", "gasUsed": "0x666d", "logs":
         [{"address": "0xdac17f958d2ee523a2206206994597c13d831ec7", "blockHash": "0xb1bafee9dceb78e91ba7fdf65abd75daccc4e2083dce83b425c1fcb427600ab9", "blockNumber": "0x8d2b29", "data": "0x0000000000000000000000000000000000000000000000000000000368b05b10", "logIndex": "0x98", "removed": false, "topics": ["0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef", "0x00000000000000000000000073595076f9e30106e1908ed735965ef727ccb64c", "0x000000000000000000000000fdb16996831753d5331ff813c29a93c76834a0ad"], "transactionHash": "0x8767e8532bd1db6340afd2f88bc8ca6c27a569916460e81963488ec8060bd548", "transactionIndex": "0xbe", "transactionLogIndex": "0x0", "type": "mined"}],
         "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000010000010000000002000040000000000000000000000000000000000004000000000100000000000000000000000000080000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000", "status": "0x1", "to": "0xdac17f958d2ee523a2206206994597c13d831ec7", "transactionHash": "0x8767e8532bd1db6340afd2f88bc8ca6c27a569916460e81963488ec8060bd548", "transactionIndex": "0xbe"}
     */

//{"blockHash": "0xb1bafee9dceb78e91ba7fdf65abd75daccc4e2083dce83b425c1fcb427600ab9", "blockNumber": "0x8d2b29", "contractAddress": null, "cumulativeGasUsed": "0x98227d", "effectiveGasPrice": "0x12a05f200", "from": "0xf857e497438d7479cf4e5461b1a386981f50f0c6", "gasUsed": "0x5208", "logs": [], "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "status": "0x1", "to": "0x999d1ce359692aebc26cd969a31d47d150128600", "transactionHash": "0x29fcc27d9bba249198b393a2ae9014f077e2ec69439f53e9e1e3d5af4caad442", "transactionIndex": "0xc5"}], "id": 1}%


/*
address: The address for which token balances were checked.
tokenBalances: An array of token balance objects. Each object contains:
contractAddress: The address of the contract.
tokenBalance: The balance of the contract, as a string representing a base-10 number.
error: An error string. One of this or tokenBalance will be null.

"{\"jsonrpc\": \"2.0\", \"id\": 1, \"result\":
{\"address\": \"0xb739d0895772dbb71a89a3754a160269068f0d45\",
    \"tokenBalances\":
    [{\"contractAddress\": \"0xdac17f958d2ee523a2206206994597c13d831ec7\", \"tokenBalance\": \"0x0000000000000000000000000000000000000000000000000000000000000000\", \"error\": null}, {\"contractAddress\": \"0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48\", \"tokenBalance\": \"0x0000000000000000000000000000000000000000000000000000000000000000\", \"error\": null}, {\"contractAddress\": \"0xf5d669627376ebd411e34b98f19c868c8aba5ada\", \"tokenBalance\": \"0x0000000000000000000000000000000000000000000000000000000000000000\", \"error\": null}, {\"contractAddress\": \"0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2\", \"tokenBalance\": \"0x0000000000000000000000000000000000000000000000000000000000000000\", \"error\": null}, {\"contractAddress\": \"0x514910771af9ca656af840dff83e8264ecf986ca\", \"tokenBalance\": \"0x0000000000000000000000000000000000000000000000000000000000000000\", \"error\": null}, {\"contractAddress\": \"0xa2120b9e674d3fc3875f415a7df52e382f141225\", \"tokenBalance\": \"0x0000000000000000000000000000000000000000000000000000000000000000\", \"error\": null}, {\"contractAddress\": \"0xae12c5930881c53715b369cec7606b70d8eb229f\", \"tokenBalance\": \"0x0000000000000000000000000000000000000000000000000000000000000000\", \"error\": null}, {\"contractAddress\": \"0xbb0e17ef65f82ab018d8edd776e8dd940327b28b\", \"tokenBalance\": \"0x0000000000000000000000000000000000000000000000000000000000000000\", \"error\": null}, {\"contractAddress\": \"0x3845badade8e6dff049820680d1f14bd3903a5d0\", \"tokenBalance\": \"0x0000000000000000000000000000000000000000000000000000000000000000\", \"error\": null}, {\"contractAddress\": \"0xdf574c24545e5ffecb9a659c229253d4111d87e1\", \"tokenBalance\": \"0x0000000000000000000000000000000000000000000000000000000000000000\", \"error\": null}, {\"contractAddress\":
*/
