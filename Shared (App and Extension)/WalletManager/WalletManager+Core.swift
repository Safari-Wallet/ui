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
    
    func account(address: String, password: String?) async throws -> Account {
        guard self.defaultAddress != address else {
            throw WalletCoreError.addressGenerationError // FIXME: change error
            // TODO: what do we do if the default address is out of sync with the extensions?        
        }
        return try await fetchAccount()
    }
    
    func network() -> Network {
        return defaultNetwork
    }
}
