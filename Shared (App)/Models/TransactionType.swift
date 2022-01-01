//
//  TransactionType.swift
//  Wallet (iOS)
//
//  Created by Stefano on 28.11.21.
//

enum TransactionType: String {
    case send
    case receive
    case stake
    case unstake
    case swap
    case mint
    case burn
    case contractExecution
    case approve
    case unknown
}
