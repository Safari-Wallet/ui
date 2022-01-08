//
//  UserSettings+Core.swift
//  Wallet
//
//  Created by Ronald Mannak on 11/7/21.
//

import Foundation
import SafariWalletCore
import MEWwalletKit

extension UserSettings: SafariWalletCoreDelegate {
    
    func addresses() -> [String]? {
        guard let address = self.address else { return nil }
        return [address.addressString]
    }
    
    func client() -> EthereumClient? {
        let key: String
        if case .ropsten = network {
            key = ApiKeys.alchemyRopsten
        } else {
            key = ApiKeys.alchemyMainnet
        }
        return AlchemyClient(network: network, key: key)
    }
    
    func account(address: String, password: String?) async throws -> Account {
        let bundles = try await AddressBundle.loadAddressBundles(network: .ethereum)

        for bundle in bundles {
            for (index, bundleAddress) in bundle.addresses.enumerated() {
                if address == bundleAddress.addressString {
                    return try await bundle.account(forAddressIndex: index, network: network, password: password)
                }
            }
        }

        throw WalletError.addressNotFound(address)
    }
    
    func currentNetwork() -> Network {
        return network
    }
}
