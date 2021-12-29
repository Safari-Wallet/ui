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
        guard let bundles = addressBundles, let index = defaultAddressBundleIndex else { return nil }
        let defaultBundle = bundles[index]
        return [defaultBundle.addresses[defaultBundle.defaultAddressIndex].address.address]
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
        guard let bundles = self.addressBundles else { throw WalletError.addressNotFound(address) }
        
        for bundle in bundles {
            for (index, bundleAddress) in bundle.addresses.enumerated() {
                if address == bundleAddress.address.address {
                    return try await bundle.account(forAddressIndex: index, password: password)
                }
            }
        }
        throw WalletError.addressNotFound(address)
    }
    
    func network() -> Network {
        return defaultNetwork
    }
}
