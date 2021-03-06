//
//  UserSettings+debug.swift
//  Wallet
//
//  Created by Ronald Mannak on 11/23/21.
//

import Foundation
import SafariWalletCore

// MARK: - Debugging methods
#if DEBUG
extension UserSettings {
    
    func deleteAllWalletsAndBundles(allFiles: Bool = false) async throws {

        if allFiles == true {
            
            // 1. Delete all files
            let allFiles = try SharedDocument.listFiles().map { $0.url }
            for file in allFiles {
                try FileManager.default.removeItem(at: file)
            }
            
        } else {
            
            // 1. Delete wallet files and remove keychain items
            let wallets = try SharedDocument.list(fileExtension: ADDRESSBUNDLE_FILE_EXTENSION).map{ $0.url }
            for wallet in wallets {
                try FileManager.default.removeItem(at: wallet)
                let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName,
                                                        account: wallet.deletingPathExtension().lastPathComponent,
                                                        accessGroup: KeychainConfiguration.accessGroup)
                try passwordItem.deleteItem()
            }
            
            // 2. Delete address bundles
            let ethereumAddresses = try SharedDocument.listAddressBundles(network: .ethereum)
            for address in ethereumAddresses {
                try FileManager.default.removeItem(at: address.url)
            }
            let ropstenAddresses = try SharedDocument.listAddressBundles(network: .ropsten)
            for address in ropstenAddresses {
                try FileManager.default.removeItem(at: address.url)
            }
            let bitcoinAddresses = try SharedDocument.listAddressBundles(network: .bitcoin)
            for address in bitcoinAddresses {
                try FileManager.default.removeItem(at: address.url)
            }
        }
        
        // 3. Reset userdefaults
        sharedContainer.removeObject(forKey: UserSettings.devModeKey)
        sharedContainer.removeObject(forKey: UserSettings.bundleKey)
        sharedContainer.synchronize()
    }
}
#endif
