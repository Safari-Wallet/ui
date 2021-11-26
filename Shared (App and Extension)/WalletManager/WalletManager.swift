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
    @Published private (set) var defaultAddress: String?
    @Published private (set) var defaultAddressBundle: AddressBundle?
    @Published private (set) var defaultNetwork: Network = .ethereum
    {
        didSet {
            saveUserDefault(key: "DefaultNetwork", value: defaultNetwork.name)
        }
    }
    
    // MARK: - Lifecycle
    
    func setup() async throws {
        if let sharedContainer = UserDefaults(suiteName: APP_GROUP), let networkName = sharedContainer.string(forKey: "DefaultNetwork"), let network = Network(name: networkName) {
            try await setup(network: network)
        } else {
            try await setup(network: .ethereum)
        }
    }
    
    func setup(network: Network) async throws {
        addressBundles = nil
        do {
            self.addressBundles = try await AddressBundle.loadAddressBundles(network: network)
        } catch {
            self.addressBundles = nil
            throw error
        }
            
        let defaultAddressBundleIndex: Int?
        let defaultAddressIndex: Int?
        
        if let sharedContainer = UserDefaults(suiteName: APP_GROUP) {
            defaultAddressBundleIndex = sharedContainer.integer(forKey: "DefaultAddressBundleIndex")
            defaultAddressIndex = sharedContainer.integer(forKey: "DefaultAddressIndex")
        } else if self.addressBundles!.count > 0 {
            defaultAddressBundleIndex = 0
            defaultAddressIndex = self.addressBundles!.first!.lastSelectedIndex
        } else {
            // addressBundles.count is 0
            return
        }

        self.defaultAddressBundleIndex = defaultAddressBundleIndex
        self.defaultAddressIndex = defaultAddressIndex
        self.defaultNetwork = network
        
        self.defaultAddress = self.addressBundles![defaultAddressBundleIndex!].addresses[defaultAddressIndex!].address.debugDescription
        self.defaultAddressBundle = self.addressBundles![defaultAddressBundleIndex!]
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
        self.defaultAddress = addressBundles[defaultAddressBundleIndex].addresses[index].address.debugDescription
        addressBundles[defaultAddressBundleIndex].lastSelectedIndex = index
    }
    
    func setDefaultNetwork(_ network: Network) async throws {
        try await setup(network: network)
    }
}

// MARK: -
//extension WalletManager {
//    
//    func createNewWallet(mnemonic: String, accountsCount: Int, password: String, storePasswordInKeychain: Bool = true, filename: String = UUID().uuidString) async throws -> String {
//        
//        // 1. Store HDWallet recovery phrase
//        try await saveKeystore(mnemonic: mnemonic, password: password, name: filename)
//        
//        // 2. Store password in keychain
//        if storePasswordInKeychain == true {
//            let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName,
//                                                    account: filename,
//                                                    accessGroup: KeychainConfiguration.accessGroup)
//            try passwordItem.savePassword(password, userPresence: true, reusableDuration: 1200) // 20 minutes
//        }
//                
//        return filename
//    }
//}

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


