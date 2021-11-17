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
    var to: Address { get }
    var type: String { get }
    var value: String { get }
    var source: String { get }
    
    var hash: String { get }
    var block: Block { get }
    
    var underlyingObject: Any { get}
}


struct WalletTransactionType: Identifiable {

    let transaction: WalletTransaction
    let id = UUID()
    
}

struct WalletTransactionV2 {
    
    
    
}

extension AlchemyAssetTransfer: WalletTransaction {   
    
    var block: Block {
        return self.blockNum
    }
    
    var underlyingObject: Any {
        self
    }
    
    var to: Address {
        Address(raw: "hello.world")
    }
    
    var from: Address {
        Address(raw: "hello.world")
    }
    
    var type: String {
        "Type"
    }
    
    var value: String {
        "Value"
    }
    
    var source: String {
        "Source"
    }
    
}

extension Unmarshal.TokenTransaction: WalletTransaction {
    
    var block: Block {
        return Block(rawValue: self.blockNumber)
    }
    
    var underlyingObject: Any {
        self
    }
    
    var to: Address {
        Address(raw: "hello.world")
    }
    
    var from: Address {
        Address(raw: "hello.world")
    }
    
    var type: String {
        "Type"
    }
    
    var value: String {
        "Value"
    }
    
    var source: String {
        "Source"
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
    
    var to: Address {
        Address(raw: "hello.world")
    }
    
    var from: Address {
        Address(raw: "hello.world")
    }
    
    var type: String {
        "Type"
    }
    
    var value: String {
        "Value"
    }
    
    var source: String {
        "Source"
    }
    
}
