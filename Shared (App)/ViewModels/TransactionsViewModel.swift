//
//  TransactionsViewModel.swift
//  Wallet
//
//  Created by Nathan Clark on 10/30/21.
//

import Combine
import Foundation
import SafariWalletCore

// TODO:
// - Implement paging
final class TransactionsListViewModel: ObservableObject {
    
    enum State {
        case loading
        case fetched(txs: [TransactionViewModel])
        case error(message: String)
    }
    
    @Published var state: State = .loading
    @Published var filter: TransactionFilter = .all
    
    private let chain: String
    private let address: String
    private let currency: String
    private let symbol: String
    private let service: TransactionFetchable
    private var cancellables = Set<AnyCancellable>()
    
    init(chain: String,
         address: String,
         currency: String,
         symbol: String,
         service: TransactionFetchable = TransactionService()) {
        self.chain = chain
        self.address = address
        self.currency = currency
        self.symbol = symbol
        self.service = service
        fetchTransactions()
        handleFilterChange()
    }
    
    func fetchTransactions() {
        state = .loading
        Task {
            do {
                var transactions = [AlchemyAssetTransfer]()
                
                switch self.filter {
                case .sent:
                    transactions = try await service.fetchSentTransactions(chain: chain, address: address, currency: currency, symbol: symbol)
                case .received:
                    transactions = try await service.fetchReceivedTransactions(chain: chain, address: address, currency: currency, symbol: symbol)
                default:
                    transactions = try await service.fetchAllTransactions(chain: chain, address: address, currency: currency, symbol: symbol)
                }
                
                let viewModels = transactions
                    .sorted { ($0.blockNum.intValue ?? 0) > ($1.blockNum.intValue ?? 0) }
                    .map(TransactionViewModel.init)
                
                state = .fetched(txs: viewModels)
            } catch let error {
                //TODO: Error handling / Define error cases and appropriate error messages
                print(error)
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

extension TransactionViewModel {

    init(tx: AlchemyAssetTransfer) {
        self.init(
            hash: tx.hash,
            blockNum: tx.blockNum.intValue.flatMap(String.init) ?? "",
            fromAddress: tx.from.address,
            toAddress: tx.to?.address,
            value: String(tx.value ?? 0.0), // TODO: Handle formatting
            erc721TokenId: tx.erc721TokenId,
            asset: tx.asset ?? "",
            category: tx.category?.rawValue ?? ""
        )
    }
    
    static var placeholder: TransactionViewModel {
        .init(
            hash: "",
            blockNum: "",
            fromAddress: "0x225e9b54f41f44f42150b6aaa730da5f2d23faf2",
            toAddress: "0x225e9b54f41f44f42150b6aaa730da5f2d23faf2",
            value: "0.0",
            erc721TokenId: nil,
            asset: "ETH",
            category: "external"
        )
    }
}

enum TransactionFilter: Int {
    case all
    case sent
    case received
    case interactions
    case failed
}
