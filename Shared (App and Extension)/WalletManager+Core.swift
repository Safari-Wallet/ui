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
    func network() -> Network {
        return defaultNetwork
    }
}
