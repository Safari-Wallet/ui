//
//  Keystore.swift
//  Wallet
//
//  Created by Ronald Mannak on 11/24/21.
//

import Foundation
import SafariWalletCore
import MEWwalletKit

extension KeystoreV3 {
    
    convenience init(bip39: BIP39, password: String) async throws {
        
        // 1. Create keystore V3
        guard let entropy = bip39.entropy,
              let passwordData = password.data(using: .utf8)?.sha256()
        else {
            throw WalletError.invalidInput(nil)
        }
        try await self.init(privateKey: entropy, passwordData: passwordData)
    }
    
    func save(name: String) async throws {
        let hdWalletFile = try SharedDocument(filename: name.deletingPathExtension().appendPathExtension(KEYSTORE_FILE_EXTENSION))
        try await hdWalletFile.write(try self.encodedData())
    }
 
    static func load(name: String, password: String? = nil, language: BIP39Wordlist = .english) async throws -> BIP39 {
        
        // 1. Load keystore
        let keystoreData = try await SharedDocument(filename: name.deletingPathExtension().appendPathExtension(KEYSTORE_FILE_EXTENSION)).read()
        let keystore = try KeystoreV3(keystore: keystoreData)
        
        // 2. Fetch password from keychain
        let pw: String
        if let password = password {
            pw = password
        } else {
            let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName, account: name.deletingPathExtension(), accessGroup: KeychainConfiguration.accessGroup)
            pw = try passwordItem.readPassword()
        }
        guard let pwData = pw.data(using: .utf8)?.sha256() else {
            throw WalletError.invalidPassword
        }
        
        // 3. Decrypt entropy
        guard let entropy = try await keystore.getDecryptedKeystore(passwordData: pwData) else {
            throw WalletError.wrongPassword
        }
        return BIP39(entropy: entropy, language: language)
    }
}
 
