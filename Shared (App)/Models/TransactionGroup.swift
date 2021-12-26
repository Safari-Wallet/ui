//
//  TransactionGroup.swift
//  Wallet
//
//  Created by Tassilo von Gerlach on 11/16/21.
//

import Foundation
import SafariWalletCore
import MEWwalletKit

struct TransactionGroup: Comparable, Identifiable {

    let transactionHash: String
    var transactions: [WalletTransaction]
    
    var id: String {
        self.transactionHash
    }
    
    var fromAddress: String {
        return transactions.first?.from.address ?? "n/a"
    }
    
    var toAddress: String {
        return transactions.first?.to?.address ?? "n/a"
    }
    
    var type: String {
        return transactions.first?.type ?? "n/a"
    }
    
    var value: String {
        return transactions.first?.transactionValue ?? "n/a"
    }
    
    var description: String {
        return transactions.first?.transactionDescription ?? "n/a"
    }
    
    var contractName: String?
    
    var inputData: String?
    
    var methodName: String?
    
    var input: [String: String]?
    
    var inputDescription: String?
    
    static func < (lhs: TransactionGroup, rhs: TransactionGroup) -> Bool {
        guard let lhsBlock = lhs.transactions.first?.block.intValue,
              let rhsBlock = rhs.transactions.first?.block.intValue else {
                  return false
              }
        return lhsBlock > rhsBlock
    }
    
    static func == (lhs: TransactionGroup, rhs: TransactionGroup) -> Bool {
        return lhs.transactionHash == rhs.transactionHash
    }
    
}
