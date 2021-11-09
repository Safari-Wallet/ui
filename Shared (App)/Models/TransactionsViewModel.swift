//
//  TransactionsViewModel.swift
//  Wallet
//
//  Created by Nathan Clark on 10/30/21.
//

import Foundation
import Combine
import Alamofire
import SafariWalletCore

class TransactionsViewModel: ObservableObject {
   
    @Published var transactions = [Covalent.Transaction]()

    init(chain: String, address: String, currency: String, symbol: String) {
        retrieveTransactionsAll(chain: chain,
                                address: address,
                                currency: currency,
                                symbol: symbol)
    }
    
    func retrieveTransactionsAll(chain: String,
                                 address: String,
                                 currency: String,
                                 symbol: String) {
        Task {
            do {
                guard let client = CovalentClient(covalentKey: covalentKey) else {
                    //TODO: Error handling
                    fatalError("TODO: Error handling")
                }
                let transactions = try await client.getTransactions(chain: chain,
                                                                    address: address,
                                                                    currency: currency,
                                                                    symbol: symbol)
                self.transactions = transactions
            } catch {
                //TODO: Error handling
                fatalError("TODO: Error handling")
            }
        }
    }
}
