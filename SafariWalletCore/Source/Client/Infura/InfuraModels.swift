//
//  InfuraModels.swift
//  Wallet
//
//  Created by Ronald Mannak on 10/28/21.
//

import Foundation
import BigInt
import MEWwalletKit

struct Log: Equatable, Decodable {
    public let logIndex: BigUInt?
    public let transactionIndex: BigUInt?
    public let transactionHash: String?
    public let blockHash: String?
    public let blockNumber: Block
    public let address: Address
    public var data: String
    public var topics: [String]
    public let removed: Bool
}

