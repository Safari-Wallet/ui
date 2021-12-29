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
            }
        }
    }
    
    @Published var defaultAddressBundleIndex: Int?
    {
        didSet {
            guard let defaultAddressBundleIndex = defaultAddressBundleIndex, let addressBundles = self.addressBundles, addressBundles.count > defaultAddressBundleIndex else {
                saveUserDefault(key: "DefaultAddressBundleIndex", value: nil)
                return
            }
            saveUserDefault(key: "DefaultAddressBundleIndex", value: defaultAddressBundleIndex)
        }
    }
    
    @Published private (set) var defaultNetwork: Network = .ethereum
    {
        didSet {
            guard defaultNetwork.chainID != oldValue.chainID else { return }
            resetDefaults()
            Task {
                try? await self.setup(network: defaultNetwork)
            }
        }
    }
    
    private func resetDefaults() {
        self.addressBundles = nil
        self.defaultAddressBundleIndex = nil
    }
    
    // MARK: - Lifecycle
    
    @MainActor
    func setup() async throws {
        assert(Thread.isMainThread)
        if let sharedContainer = UserDefaults(suiteName: APP_GROUP), let networkName = sharedContainer.string(forKey: "DefaultNetwork") {
            let network = Network(name: networkName)
            try await setup(network: network)
        } else {
            try await setup(network: .ethereum)
        }
    }
    
    @MainActor
    func setup(network: Network) async throws {
        assert(Thread.isMainThread)
        // 1. Reset defaults
        resetDefaults()
        
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
        print("address bundles found: \(addressBundles.count)")
            
        // 4. Restore previous defaults from NSUserDefaults
        if let sharedContainer = UserDefaults(suiteName: APP_GROUP) {
            let bundleIndex = sharedContainer.integer(forKey: "DefaultAddressBundleIndex")
            let addressIndex = sharedContainer.integer(forKey: "DefaultAddressIndex")
            if addressBundles.count > bundleIndex && addressBundles[bundleIndex].addresses.count > addressIndex {
                self.defaultAddressBundleIndex = bundleIndex
            }
        }
        
        // 5. If no valid default address was found, default to first address bundle
        if self.defaultAddressBundleIndex == nil {
            self.defaultAddressBundleIndex = 0
        }
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
