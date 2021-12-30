//
//  AddressBundle+Storage.swift
//  Wallet
//
//  Created by Ronald Mannak on 12/29/21.
//

import Foundation
import SafariWalletCore
import MEWwalletKit

extension AddressBundle {
    
    /// If false, address bundle is view only
    var canSign: Bool {
        switch type {
        case .keystorePassword:
            return keystoreExists
        case .keystoreSecureEnclave:
            return keystoreExists
        case .viewOnly:
            return false
        case .nanoLedgerX(id: _, bip44: _):
            return true
        case .nanoLedgerS(id: _, bip44: _):
            #if os(macOS)
            return true
            #else
            return false
            #endif
        case .trezor(_):
            #if os(macOS)
            return true
            #else
            return false
            #endif
        }
    }
    
    var keystoreExists: Bool {
        guard let walletURL = try? URL.sharedContainer().appendingPathComponent(id.uuidString).appendingPathComponent(KEYSTORE_FILE_EXTENSION) else {
            return false
        }
        return FileManager.default.fileExists(atPath: walletURL.path)
    }
    
    static func loadAddressBundles(network: Network) async throws -> [AddressBundle] {
        let documents = try SharedDocument.listAddressBundles(network: network)
        var bundles = [AddressBundle]()
        for document in documents {
            guard let data = try? await document.read(), let bundle = try? JSONDecoder().decode(AddressBundle.self, from: data) else { continue }
            bundles.append(bundle)
        }
        return bundles
    }
    
    static func load(id: UUID, network: Network) async throws -> AddressBundle {
        let filename = try id.uuidString.appendPathExtension(network.symbol).appendPathExtension(ADDRESSBUNDLE_FILE_EXTENSION)
        let document = try SharedDocument(filename: filename)
        let data = try await document.read()
        let bundle = try JSONDecoder().decode(AddressBundle.self, from: data)
        return bundle
    }
    
    func save() async throws {
        let document = try SharedDocument(filename: self.id.uuidString.appendPathExtension(network.symbol).appendPathExtension(ADDRESSBUNDLE_FILE_EXTENSION))
        let data = try JSONEncoder().encode(self)
        try await document.write(data)
    }
}

// MARK: -- NSUserDefaults

extension AddressBundle {
    
    func setDefault(index: Int) {
        guard index < addresses.count, let sharedContainer = UserDefaults(suiteName: APP_GROUP) else {
            assertionFailure()
            return
        }
        
        sharedContainer.set(self.id.uuidString, forKey: "DefaultAddressBundle")
        sharedContainer.set(network.name, forKey: "DefaultNetwork")
        sharedContainer.synchronize()
    }
    
    static func loadDefault() async throws -> AddressBundle {
        guard
            let sharedContainer = UserDefaults(suiteName: APP_GROUP),
            let bundleID = sharedContainer.string(forKey: "DefaultAddressBundle"),
            let networkName = sharedContainer.string(forKey: "DefaultNetwork"),
            let uuid = UUID(uuidString: bundleID)
        else {
            throw WalletError.noDefaultWalletSet
        }
        return try await load(id: uuid, network: Network(name: networkName))
    }
}

extension AddressBundle {
    
    func account(forAddressIndex: Int, password: String?) async throws -> Account {
        
        // 1. Sanity check
        guard canSign == true else { throw WalletError.viewOnly }
        guard forAddressIndex < self.addresses.count else { throw WalletError.outOfBounds }
                
        switch type {
        case .keystoreSecureEnclave:
            throw WalletError.notImplemented
        case .keystorePassword:
            let bip39 = try await KeystoreV3.load(name: id.uuidString, password: password)
            guard let seed = try bip39.seed() else { throw WalletError.seedError }
            let wallet = try Wallet<PrivateKeyEth1>(seed: seed)
            let account = try Account(privateKey: wallet.privateKey, wallet: id.uuidString, derivationpath: "123") // FIXME: derivationpath
            assert(account.addresss.address == addresses[forAddressIndex].addressString)
            return account
        case .viewOnly:
            throw WalletError.viewOnly
        case .nanoLedgerX(id: _, bip44: _):
            throw WalletError.notImplemented
        case .nanoLedgerS(id: _, bip44: _):
            throw WalletError.notImplemented
        case .trezor(id: _):
            throw WalletError.notImplemented
        }
    }
}