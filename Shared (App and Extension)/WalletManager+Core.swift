//
//  WalletManager+Core.swift
//  Wallet
//
//  Created by Ronald Mannak on 11/7/21.
//

import Foundation
import SafariWalletCore
import MEWwalletKit

extension WalletManager: SafariWalletCoreDelegate {
    
    func addresses() -> [String]? {
        guard let address = defaultAddress else { return nil }
        return [address]
    }
    
    func client() -> EthereumClient? {
        let key: String
        if case .ropsten = defaultNetwork {
            key = alchemyRopstenKey
        } else {
            key = alchemyMainnetKey
        }
        return AlchemyClient(network: defaultNetwork, key: key)
    }
    
//    func account(address: String, password: String?) async throws -> Account {
//        guard let defaultAddress = self.defaultAddress, let defaultWallet = self.defaultWallet, address == defaultAddress else {
//            // FIXME: if address used by extension is out of sync with wallet,
//            throw WalletError.addressNotFound
//        }
//        let wallet = await try loadWallet(name: defaultWallet, password: password, network: defaultNetwork)
//    }
    
    func network() -> Network {
        return defaultNetwork
    }
}
