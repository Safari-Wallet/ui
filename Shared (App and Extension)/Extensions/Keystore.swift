//
//  Keystore.swift
//  Wallet
//
//  Created by Ronald Mannak on 11/24/21.
//

import Foundation
import SafariWalletCore

extension KeystoreV3 {
    
    convenience init?(mnemonic: String, password: String) async throws {
        
        // 1. Create keystore V3
        guard let phraseData = mnemonic.data(using: .utf8),
              let passwordData = password.data(using: .utf8)?.sha256()
        else {
            throw WalletError.invalidInput(nil)
        }
        try await self.init(privateKey: phraseData, passwordData: passwordData)
    }
    
    /// Saves keystore to disk
    /// - Parameters:
    ///   - name: filename (without file extension)
    ///   - storePasswordInKeychain: if true, password will be stored. Default is true.
    ///   - resuableDuration: Time password can be used without FaceID/TouchID verification. Default is 1200 seconds (20 minutes)
    func save(name: String, password: String, storePasswordInKeychain: Bool = true, resuableDuration: TimeInterval = 1200) async throws {
        try await save(name: name)

        if storePasswordInKeychain == true {
            let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName,
                                                    account: name,
                                                    accessGroup: KeychainConfiguration.accessGroup)
            try passwordItem.savePassword(password, userPresence: true, reusableDuration: resuableDuration)
        }
    }
    
    func save(name: String) async throws {
        let hdWalletFile = try SharedDocument(filename: name.deletingPathExtension().appendPathExtension(KEYSTORE_FILE_EXTENSION))
        try await hdWalletFile.write(try self.encodedData())
    }
 
    static func loadMnemonic(name: String, password: String? = nil) async throws -> String {
        
        // 1. Load keystore
        let keystoreData = try await SharedDocument(filename: name.deletingPathExtension().appendPathExtension(KEYSTORE_FILE_EXTENSION)).read()
        guard let keystore = try KeystoreV3(keystore: keystoreData) else {
            throw WalletError.errorOpeningKeyStore(name)
        }
        
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
        
        // 3. Decrypt mnemonic
        guard let mnemonicData = try await keystore.getDecryptedKeystore(passwordData: pwData) else {
            throw WalletError.wrongPassword
        }
        return String(decoding: mnemonicData, as: UTF8.self)
    }
}
 
