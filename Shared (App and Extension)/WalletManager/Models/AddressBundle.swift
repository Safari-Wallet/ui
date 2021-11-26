//
//  AddressBundle.swift
//  Wallet
//
//  Created by Ronald Mannak on 11/17/21.
//

import Foundation
import SafariWalletCore
import MEWwalletKit

class AddressBundle: Identifiable, ObservableObject, Codable {
    
    var id: UUID
    
    /// Human readable, end-user defined name
    @Published var walletName: String? 
    
    @Published private (set) var addresses: [AddressItem]
    
    var lastSelectedIndex: Int = 0
    
    let type: PrivateKeyType
    
    let network: Network // Supported: "Ropsten", "Ethereum", "Ethereum - Ledger Live"
    
    init(walletName: String? = nil, type: PrivateKeyType, network: Network, addresses: [AddressItem]) {
        id = UUID()
        self.walletName = walletName
        self.addresses = addresses
        self.type = type
        self.network = network
    }
    
    enum CodingKeys: CodingKey {
        case id
        case walletName
        case addresses
        case type
        case network
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        walletName = try container.decode(String?.self, forKey: .walletName)
        addresses = try container.decode([AddressItem].self, forKey: .addresses)
        type = try container.decode(PrivateKeyType.self, forKey: .type)
        network = try container.decode(Network.self, forKey: .network)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(walletName, forKey: .walletName)
        try container.encode(addresses, forKey: .addresses)
        try container.encode(type, forKey: .type)
        try container.encode(network, forKey: .network)
    }
}

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
    
    static func loadAddressBundles(network: Network) async throws -> [AddressBundle]? {
        let documents = try SharedDocument.listAddressBundles(network: network)
        var bundles = [AddressBundle]()
        for document in documents {
            guard let data = try? await document.read(), let bundle = try? JSONDecoder().decode(AddressBundle.self, from: data) else { continue }
            bundles.append(bundle)
        }
        return bundles
    }
    
    func save() async throws {
        let document = try SharedDocument(filename: self.id.uuidString.appendPathExtension(network.symbol).appendPathExtension(ADDRESSBUNDLE_FILE_EXTENSION))
        let data = try JSONEncoder().encode(self)
        try await document.write(data)
    }
}

extension AddressBundle {
    
    func account(forAddressIndex: Int, password: String?) async throws -> Account {
        
        // 1. Sanity check
        guard canSign == true else { throw WalletError.viewOnly }
        guard forAddressIndex < self.addresses.count else { throw WalletError.outOfBounds }
        
        // 2. Fetch mnemonic
        let mnemonic: String
        switch type {
        case .keystoreSecureEnclave:
            throw WalletError.notImplemented
        case .keystorePassword:
            mnemonic = try await KeystoreV3.loadMnemonic(name: id.uuidString, password: password)
            
        case .viewOnly:
            throw WalletError.viewOnly
        case .nanoLedgerX(id: _, bip44: _):
            throw WalletError.notImplemented
        case .nanoLedgerS(id: _, bip44: _):
            throw WalletError.notImplemented
        case .trezor(id: _):
            throw WalletError.notImplemented
        }
        
        // 2. Restore wallet from mnemonic
        guard let seed = try BIP39(mnemonic: mnemonic.components(separatedBy: " ")).seed() else { throw WalletError.seedError }
        let wallet = try Wallet<PrivateKeyEth1>(seed: seed)
                
        // 3. Create account based on derivation path
        let account = try Account(privateKey: wallet.privateKey, wallet: id.uuidString, derivationpath: "123")
        assert(account.addresss == addresses[forAddressIndex].address)
        return account
    }
}
