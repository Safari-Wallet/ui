//
//  TransactionViewModel.swift
//  Wallet
//
//  Created by Stefano on 01.01.22.
//

import BigInt
import Foundation
import MEWwalletKit

struct TransactionViewModel: Identifiable {
    var id: UUID
    let hash: String
    let fromAddress: String
    let toAddress: String?
    let tokenValue: String?
    let tokenSymbol: String?
    let fiatValue: String?
    let currency: String?
    let type: TransactionType
}

extension TransactionViewModel {
    
    init(tx: TransactionActivity) {
        let token = TransactionViewModel.mapToToken(tx: tx)
        let currency = TransactionViewModel.mapToCurrency(tx: tx)
        let from = TransactionViewModel.mapToTruncatedAddress(tx.from)
        let to = tx.to.flatMap(TransactionViewModel.mapToTruncatedAddress)
        self.init(
            id: UUID(),
            hash: tx.txHash,
            fromAddress: from,
            toAddress: to,
            tokenValue: token?.value,
            tokenSymbol: token?.symbol,
            fiatValue: currency?.value, // Should we use current prices or prices at time of tx?
            currency: currency?.symbol,
            type: tx.type
        )
    }
    
    static func mapToTruncatedAddress(_ address: Address) -> String {
        return address.address.prefix(5) + "..." + address.address.suffix(5)
    }
    
    static func mapToToken(tx: TransactionActivity) -> (value: String, symbol: String)? {
        switch tx.type {
        case .send: // stake, deployment, deposit, repay
            guard let asset = tx.assets.out else { return nil }
            return mapToToken(asset: asset)
        default:
            guard let asset = tx.assets.in else { return nil }
            return mapToToken(asset: asset)
        }
    }
    
    static func mapToToken(asset: Asset) -> (value: String, symbol: String)? {
        switch asset {
        case .native(let asset):
            return (
                value: String(asset.value.convert(withDecimals: asset.decimal).rounded(toPlaces: 4)),
                symbol: asset.symbol
            )
        case .erc20(let asset):
            return (
                value: String(asset.value.convert(withDecimals: asset.decimal).rounded(toPlaces: 4)),
                symbol: asset.symbol
            )
        }
    }
    
    static func mapToCurrency(tx: TransactionActivity) -> (value: String, symbol: String)? {
        switch tx.type {
        case .send: // stake, deployment, deposit, repay
            guard let asset = tx.assets.out else { return nil }
            return mapToCurrency(asset: asset)
        default:
            // check for ens registrations (type trade)
            guard let asset = tx.assets.in else { return nil }
            return mapToCurrency(asset: asset)
        }
    }
    
    static func mapToCurrency(asset: Asset) -> (value: String, symbol: String)? {
        switch asset {
        case .native(let asset):
            guard let price = asset.price else { return nil }
            return (
                value: String(asset.value.convert(withDecimals: asset.decimal) * price.value),
                symbol: asset.symbol
            )
        case .erc20(let asset):
            guard let price = asset.price else { return nil }
            return (
                value: String(asset.value.convert(withDecimals: asset.decimal) * price.value),
                symbol: asset.symbol
            )
        }
    }
}



// TODO: Move to extensions folder

extension BigInt {
    
    func convert(withDecimals decimals: Int) -> Double {
        if decimals == 0 { return Double(self) }
        return Double(self) / pow(Double(10),Double(decimals))
    }
}

extension Double {

    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
