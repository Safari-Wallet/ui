//
//  TransactionGroup.swift
//  Wallet
//
//  Created by Tassilo von Gerlach on 11/16/21.
//

import Foundation
import SafariWalletCore

struct TransactionGroup: Comparable {
    
    let transactionHash: String
    var transactions: [WalletTransaction]
    
    static func < (lhs: TransactionGroup, rhs: TransactionGroup) -> Bool {
        guard let lhsBlock = lhs.transactions.first?.block,
              let rhsBlock = rhs.transactions.first?.block else {
                  return false
              }
        return lhsBlock < rhsBlock
    }
    
    static func == (lhs: TransactionGroup, rhs: TransactionGroup) -> Bool {
        return lhs.transactionHash == rhs.transactionHash
    }
    
}
