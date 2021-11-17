//
//  TransactionsViewModel.swift
//  Wallet
//
//  Created by Nathan Clark on 10/30/21.
//

import Combine
import Foundation
import SafariWalletCore
import MEWwalletKit

// TODO:
// - Implement paging
final class TransactionsListViewModel: ObservableObject {
    
    enum State {
        case loading
        case fetched(txs: [TransactionGroup])
        case error(message: String)
    }
    
    @Published var state: State = .loading
    @Published var filter: TransactionFilter = .all
    
    private let chain: String
    private let address: String
    private let currency: String
    private let symbol: String
    private let service: TransactionService
    private var cancellables = Set<AnyCancellable>()
    
    init(chain: String,
         address: String,
         currency: String,
         symbol: String,
         service: TransactionService = TransactionService()) {
        self.chain = chain
        self.address = address
        self.currency = currency
        self.symbol = symbol
        self.service = service
//        fetchTransactions()
        handleFilterChange()
    }
    
    func fetchTransactions() {
        state = .loading
        
        Task {
            do {
                switch self.filter {
                    case .all:
                        let transactions = try await self.service.fetchTransactions(network: .ethereum,
                                                                                    address: Address(ethereumAddress: "0x225E9B54F41F44F42150b6aAA730Da5f2d23FAf2")!)
                        state = .fetched(txs: transactions)
                    case .sent:
                        //TODO: Implement me!
                        state = .error(message: "Not yet implemented!")
                    case .received:
                        //TODO: Implement me!
                        state = .error(message: "Not yet implemented!")
                    case .interactions:
                        //TODO: Implement me!
                        state = .error(message: "Not yet implemented!")
                    case .failed:
                        //TODO: Implement me!
                        state = .error(message: "Not yet implemented!")
                }
            } catch let error {
                //TODO: Error handling / Define error cases and appropriate error messages
                state = .error(message: error.localizedDescription)
            }
        }
    }
    
    func handleFilterChange() {
        $filter
            .sink { [weak self] _ in
                self?.fetchTransactions()
            }
            .store(in: &cancellables)
    }
}

struct TransactionViewModel: Identifiable {
    var id: UUID = UUID()
    let hash: String
    let blockNum: String
    let fromAddress: String
    let toAddress: String?
    let value: String
    let erc721TokenId: String?
    let asset: String
    let category: String
}

//extension TransactionViewModel {
//
//    init(tx: AlchemyAssetTransfer) {
//        self.init(
//            hash: tx.hash,
//            blockNum: tx.blockNum.intValue.flatMap(String.init) ?? "",
//            fromAddress: tx.from.address,
//            toAddress: tx.to.address,
//            value: tx.value, // TODO: Handle formatting
//            erc721TokenId: tx.erc721TokenId,
//            asset: tx.asset ?? "",
//            category: tx.category?.rawValue ?? ""
//        )
//    }
//    
//    static var placeholder: TransactionViewModel {
//        .init(
//            hash: "",
//            blockNum: "",
//            fromAddress: "0x225e9b54f41f44f42150b6aaa730da5f2d23faf2",
//            toAddress: "0x225e9b54f41f44f42150b6aaa730da5f2d23faf2",
//            value: "0.0",
//            erc721TokenId: nil,
//            asset: "ETH",
//            category: "external"
//        )
//    }
//}

enum TransactionFilter: Int {
    case all
    case sent
    case received
    case interactions
    case failed
}
