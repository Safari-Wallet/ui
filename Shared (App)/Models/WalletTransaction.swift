//
//  WalletTransaction.swift
//  Wallet
//
//  Created by Tassilo von Gerlach on 11/16/21.
//

import Foundation
import MEWwalletKit
import SafariWalletCore

protocol WalletTransaction {
    var from: Address { get }
    var to: Address? { get }
    var type: String? { get }
    var transactionValue: String? { get }
    var transactionDescription: String? { get }
    var source: String { get }
    
    var hash: String { get }
    var block: Block { get }
    
    var underlyingObject: Any { get}
}

extension AlchemyAssetTransfer: WalletTransaction {
    
    var block: Block {
        return self.blockNum
    }
    
    var underlyingObject: Any {
        self
    }
    
    var type: String? {
        self.category?.rawValue
    }
    
    var transactionValue: String? {
        if let value = self.value {
            return String(value)
        } else {
            return nil
        }
    }
    
    var transactionDescription: String? {
        nil
    }
    
    var source: String {
        "Alchemy"
    }
    
}

extension Unmarshal.TokenTransaction: WalletTransaction {
    
    var block: Block {
        return Block(rawValue: self.blockNumber)
    }
    
    var underlyingObject: Any {
        self
    }
    
    var transactionValue: String? {
        let wei = Double(self.value) ?? 0
        let eth = (wei / 1000000000000000000).rounded(toPlaces: 4)
        return String(eth)
    }
    
    var transactionDescription: String? {
        self.details
    }
    
    var source: String {
        "Unmarshal"
    }
    
}

extension Covalent.Transaction: WalletTransaction {
    
    var underlyingObject: Any {
        self
    }
    
    var block: Block {
        return Block(rawValue: self.block_height)
    }
    
    var hash: String {
        return tx_hash
    }
    
    var to: Address? {
        self.to_address
    }
    
    var from: Address {
        self.from_address
    }
    
    var type: String? {
        nil
    }
    
    var transactionValue: String? {
        self.value
    }
    
    var transactionDescription: String? {
        nil
    }
    
    var source: String {
        "Covalent"
    }
    
}

extension Double {

    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
