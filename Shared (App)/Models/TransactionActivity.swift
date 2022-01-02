//
//  TransactionActivity.swift
//  Wallet
//
//  Created by Stefano on 01.01.22.
//

import BigInt
import Foundation
import MEWwalletKit
import SafariWalletCore

struct TransactionActivity: Equatable {
    let from: Address
    let to: Address?
    let txHash: String
    let type: TransactionType
    let assets: TransactedAssets
    let fee: Fee?
    let status: TransactionStatus
    let block: Block
    let minedAt: Int
    let protocolName: String?
}

enum TransactionStatus: String, Equatable {
    case confirmed
    case failed
    case pending
}

struct TransactedAssets: Equatable {
    let `in`: Asset?
    let out: Asset?
}

enum Asset: Equatable {
    case native(NativeAsset)
    case erc20(ERC20Asset)
//    case erc721(ERC721Asset)
}

struct NativeAsset: Equatable {
    let symbol: String
    let value: BigInt
    let decimal: Int
    let price: Price?
    let currentPrice: Price?
}

struct ERC20Asset: Equatable {
    let symbol: String
    let value: BigInt
    let decimal: Int
    let price: Price?
    let currentPrice: Price?
}

struct ERC721Asset: Equatable {
    // TODO
}

struct Price: Equatable {
    let value: Double
    let currency: String
}

struct Fee: Equatable {
    let value: Int
//    let decimal: Int
    let price: Price?
}

// MARK: - Zerion Mapping

extension TransactionActivity {

    init(tx: Zerion.Transaction, meta: Zerion.Meta) {
        self.init(
            from: Address(raw: tx.addressFrom.lowercased()),
            to: tx.addressTo.flatMap { Address(raw: $0.lowercased()) },
            txHash: tx.txHash,
            type: TransactionType(rawValue: tx.txType) ?? .unknown,
            assets: TransactedAssets(
                in: tx.changes?.first(where: { $0.direction == .in }).flatMap { Asset(tx: $0, meta: meta) },
                out: tx.changes?.first(where: { $0.direction == .out }).flatMap { Asset(tx: $0, meta: meta) }
            ),
            fee: tx.fee.flatMap {
                Fee(value: $0.value, price: Price(value: $0.price, currency: meta.currency))
            },
            status: TransactionStatus(rawValue: tx.status) ?? .confirmed,
            block: Block(rawValue: tx.blockNumber),
            minedAt: tx.minedAt,
            protocolName: tx.protocol
        )
    }
}

extension Asset {

    init(tx: Zerion.TransactionChange, meta: Zerion.Meta) {
//        if tx.asset.type == "nft" {
//            self = .erc721(ERC721Asset())
//        }
        if tx.asset.assetCode == "eth" {
            self = .native(
                NativeAsset(
                    symbol: tx.asset.symbol,
                    value: BigInt(tx.value),
                    decimal: tx.asset.decimals,
                    price: tx.asset.price.flatMap { Price(value: $0.value, currency: meta.currency) },
                    currentPrice: tx.price.flatMap { Price(value: $0, currency: meta.currency) }
                )
            )
        } else {
            self = .erc20(
                ERC20Asset(
                    symbol: tx.asset.symbol,
                    value: BigInt(tx.value),
                    decimal: tx.asset.decimals,
                    price: tx.asset.price.flatMap { Price(value: $0.value, currency: meta.currency) },
                    currentPrice: tx.price.flatMap { Price(value: $0, currency: meta.currency) }
                )
            )
        }
    }
}
