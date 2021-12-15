//
//  WalletManager.swift
//  Wallet
//
//  Created by Ronald Mannak on 10/9/21.
//

import Foundation
import MEWwalletKit
import SafariWalletCore
import Alamofire
import SwiftUI

final class WalletManager: ObservableObject {
    
    @Published private (set) var addressBundles: [AddressBundle]? {
        didSet {
            if addressBundles == nil {
                self.defaultAddressBundleIndex = nil
                self.defaultAddressIndex = nil
                self.defaultAddress = nil
                self.defaultAddressBundle = nil
            }
        }
    }
    @Published private (set) var defaultAddressBundleIndex: Int?
    {
        didSet {
            saveUserDefault(key: "DefaultAddressBundleIndex", value: defaultAddressBundleIndex)
        }
    }
    @Published private (set) var defaultAddressIndex: Int?
    {
        didSet {
            saveUserDefault(key: "DefaultAddressIndex", value: defaultAddressIndex)
        }
    }
    @Published private (set) var defaultAddress: AddressItem?
    @Published private (set) var defaultAddressBundle: AddressBundle?
    @Published private (set) var defaultNetwork: Network = .ethereum
    {
        didSet {
            saveUserDefault(key: "DefaultNetwork", value: defaultNetwork.name)
        }
    }
    
    // MARK: - Lifecycle
    
    func setup() async throws {
        if let sharedContainer = UserDefaults(suiteName: APP_GROUP), let networkName = sharedContainer.string(forKey: "DefaultNetwork") {
            let network = Network(name: networkName)
            try await setup(network: network)
        } else {
            try await setup(network: .ethereum)
        }
    }
    
    func setup(network: Network) async throws {
        
        // 1. Reset defaults
        self.addressBundles = nil
        self.defaultAddress = nil
        self.defaultAddressBundle = nil
        self.defaultAddressIndex = nil
        self.defaultAddressBundleIndex = nil
        self.defaultNetwork = network
        
        // 2. Load address bundles
        do {
            self.addressBundles = try await AddressBundle.loadAddressBundles(network: network)
        } catch {
            self.addressBundles = nil
            throw error
        }
        
        // 3. If there are no address bundles, we're done
        guard let addressBundles = self.addressBundles, addressBundles.count > 0 else {
            return
        }
            
        // 4. Restore previous defaults from NSUserDefaults
        if let sharedContainer = UserDefaults(suiteName: APP_GROUP) {
            let bundleIndex = sharedContainer.integer(forKey: "DefaultAddressBundleIndex")
            let addressIndex = sharedContainer.integer(forKey: "DefaultAddressIndex")
            if addressBundles.count > bundleIndex && addressBundles[bundleIndex].addresses.count > addressIndex {
                self.defaultAddressBundleIndex = bundleIndex
                self.defaultAddressIndex = addressIndex
            }
        }
        
        // 5. If no valid default address was found, default to first address bundle
        if self.defaultAddressBundleIndex == nil {
            self.defaultAddressBundleIndex = 0
            self.defaultAddressIndex = addressBundles[0].lastSelectedIndex
        }
                
        // 6. Set indices
        self.defaultAddress = addressBundles[defaultAddressBundleIndex!].addresses[defaultAddressIndex!]
        self.defaultAddressBundle = addressBundles[defaultAddressBundleIndex!]
    }
    
    // MARK: - Set Defaults
    
    func setDefaultAddressBundle(index: Int) {
        guard let addressBundles = self.addressBundles, index < addressBundles.count else {
            return
        }
        self.defaultAddressBundleIndex = index
        self.defaultAddressBundle = addressBundles[index]
        setDefaultAddress(index: addressBundles[index].lastSelectedIndex)
    }
    
    func setDefaultAddress(index: Int) {
        guard let addressBundles = self.addressBundles, let defaultAddressBundleIndex = self.defaultAddressBundleIndex, index < addressBundles[defaultAddressBundleIndex].addresses.count else {
            return
        }
        self.defaultAddressIndex = index
        self.defaultAddress = addressBundles[defaultAddressBundleIndex].addresses[index]
        addressBundles[defaultAddressBundleIndex].lastSelectedIndex = index
    }
    
    func setDefaultNetwork(_ network: Network) async throws {
        try await setup(network: network)
    }
}

// MARK: - NSUserDefaults
extension WalletManager {
    
    fileprivate func saveUserDefault(key: String, value: Any?) {
        if let sharedContainer = UserDefaults(suiteName: APP_GROUP) {
            if let value = value {
                sharedContainer.set(value, forKey: key)
            } else {
                sharedContainer.removeObject(forKey: key)
            }
            sharedContainer.synchronize()
        }
    }
    
}


