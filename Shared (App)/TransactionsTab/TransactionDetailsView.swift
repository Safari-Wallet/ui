//
//  TransactionDetailsView.swift
//  Wallet
//
//  Created by Tassilo von Gerlach on 11/17/21.
//

import SwiftUI
import SafariWalletCore

struct TransactionDetailsView: View {
    
    let group: TransactionGroup

    var body: some View {
        List {
            ForEach(group.transactions, id: \.source) { transaction in
                if let alchemyTransfer = transaction as? AlchemyAssetTransfer {
                    VStack {
                        Text(alchemyTransfer.source).font(.title)
                        Text(alchemyTransfer.description)
                    }
                } else if let covalentTransaction = transaction as? Covalent.Transaction {
                    VStack {
                        Text(covalentTransaction.source).font(.title)
                        Text(covalentTransaction.description)
                    }
                } else if let unmarshalTransaction = transaction as? Unmarshal.TokenTransaction {
                    VStack {
                        Text(unmarshalTransaction.source).font(.title)
                        Text(unmarshalTransaction.description)
                    }
                }
            }
        }
    }
    
}

extension AlchemyAssetTransfer: CustomStringConvertible {
    
    public var description: String {
        return """
        Block number: \(self.blockNum)
        Hash: \(self.hash)
        From: \(self.from.address)
        To: \(self.to?.address ?? "n/a")
        Value: \(String(describing: self.value))
        Erc721TokenId: \(self.erc721TokenId ?? "n/a")
        Asset: \(self.asset ?? "n/a")
        Category: \(String(describing: self.category))
        RawContract: \(String(describing: self.rawContract))
        """
    }
    
}

extension Covalent.Transaction: CustomStringConvertible {
    
    public var description: String {
        return """
        Block height: \(self.block_height)
        Hash: \(self.tx_hash)
        Signed At: \(self.block_signed_at)
        From: \(self.from_address)
        From Address Label: \(self.from_address_label ?? "n/a")
        To: \(self.to?.address ?? "n/a")
        To Address Label: \(self.to_address_label ?? "n/a")
        Offset: \(String(describing: self.tx_offset))
        Successful: \(String(describing: self.successful))
        Value: \(self.value ?? "n/a")
        Value Quote: \(String(describing: self.value_quote))
        Gas Offered: \(String(describing: self.gas_offered))
        Gas Spent: \(String(describing: self.gas_spent))
        Gas Price: \(String(describing: self.gas_price))
        Gas Quote: \(String(describing: self.gas_quote))
        Gas Quote Rate: \(String(describing: self.gas_quote_rate))
        Log events: \(String(describing: self.log_events))
        """
    }
    
}

extension Unmarshal.TokenTransaction: CustomStringConvertible {
    
    public var description: String {
        return """
        Block number: \(self.blockNumber)
        Hash: \(self.hash)
        From: \(self.from.address)
        To: \(self.to?.address ?? "n/a")
        Value: \(self.value)
        Fee: \(self.fee)
        Date: \(self.date)
        Type: \(self.type ?? "n/a")
        Status: \(self.status)
        Description: \(self.details)
        """
    }
    
}
