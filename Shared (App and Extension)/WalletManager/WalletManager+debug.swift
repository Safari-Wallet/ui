//
//  WalletManager+debug.swift
//  Wallet
//
//  Created by Ronald Mannak on 11/23/21.
//

import Foundation

// MARK: - Debugging methods
#if DEBUG
extension WalletManager {
    
    func deleteAllWallets() throws {
        self.addressBundles = nil
        let directory = try URL.sharedContainer()
        let wallets = try SharedDocument.list(fileExtension: ADDRESSBUNDLE_FILE_EXTENSION).map{ $0.url }
        
        for wallet in wallets {
            try FileManager.default.removeItem(at: directory.appendingPathComponent(wallet))
            let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName,
                                                    account: wallet,
                                                    accessGroup: KeychainConfiguration.accessGroup)
            try passwordItem.deleteItem()
        }
        guard let sharedContainer = UserDefaults(suiteName: APP_GROUP) else { throw WalletError.invalidAppGroupIdentifier(APP_GROUP) }
        sharedContainer.removeObject(forKey: "DefaultWallet")
        sharedContainer.synchronize()
    }
    
    func deleteAllAddresses() throws {
        self.defaultAddress = nil
        let directory = try URL.sharedContainer()
        let addresses = try listAddressFiles()
        
        for address in addresses {
            try FileManager.default.removeItem(at: directory.appendingPathComponent(address))
        }
        guard let sharedContainer = UserDefaults(suiteName: APP_GROUP) else { throw WalletError.invalidAppGroupIdentifier(APP_GROUP) }
        sharedContainer.removeObject(forKey: "DefaultAddress")
        sharedContainer.synchronize()
    }
}
#endif
