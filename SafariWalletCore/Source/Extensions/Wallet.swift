//
//  Wallet.swift
//  Wallet
//
//  Created by Ronald Mannak on 10/20/21.
//

import Foundation
import MEWwalletKit

extension Wallet {
    
    public static func createNewWallet(bitsOfEntropy: Int = 128, language: BIP39Wordlist = .english, network: Network = .ethereum) throws -> (Wallet, String) {
        let (bip39, wallet) = try Wallet.generate(bitsOfEntropy: bitsOfEntropy, language: language, network: network)
        guard let mnemonicArray = bip39.mnemonic else { throw MEWwalletKit.WalletError.emptySeed }
        let mnemonic = mnemonicArray.joined(separator: " ")
        return (wallet, mnemonic)
    }
       
    public convenience init(mnemonic: String, language: BIP39Wordlist = .english, network: Network = .ethereum) throws {
        guard let seed = try BIP39(mnemonic: mnemonic.components(separatedBy: " ")).seed() else { throw MEWwalletKit.WalletError.emptySeed }
        try self.init(seed: seed, network: network)
    }
    
    public func fetchPrivateKeyFor(index: Int) async throws -> PK {
        return try self.derive(self.privateKey.network, index: UInt32(index)).privateKey
    }
    
    /// Convenience method to generate addresses
    /// - Parameters:
    ///   - count: Number of addresses to be generated
    ///   - network: Network for addresses to be generated (default is Ethereum)
    /// - Returns: Array of addresses
    /// - Throws: WalletError.addressGenerationError if an address couldn't be generated
    public func generateAddresses(count: Int, startIndex: Int = 0, network: Network = .ethereum) throws -> [MEWwalletKit.Address] {
        var addresses = [MEWwalletKit.Address]()
        for i in startIndex ..< startIndex + count {
            guard let address = try self.derive(network, index: UInt32(i)).privateKey.address() else {
                throw WalletCoreError.addressGenerationError
            }
            addresses.append(address)
        }
        return addresses
    }
    
}
