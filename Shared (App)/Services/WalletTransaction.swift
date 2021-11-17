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
}


struct WalletTransactionType: Identifiable {

    let transaction: WalletTransaction
    let id = UUID()
    
}

extension AlchemyAssetTransfer: WalletTransaction {
    
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
