//
//  Account.swift
//  
//
//  Created by Ronald Mannak on 11/1/21.
//

import Foundation
import MEWwalletKit

public struct Account {
    
    public let addresss: Address
    public let publicKey: PublicKeyEth1
    private let privateKey: PrivateKeyEth1
    public let wallet: String
    public let derivationpath: String
    
    public init(privateKey: PrivateKeyEth1, wallet: String, derivationpath: String) throws {
        self.privateKey = privateKey
        self.publicKey = try privateKey.publicKey()
        guard let address = privateKey.address() else { throw WalletCoreError.addressGenerationError }
        self.addresss = address
        self.wallet = wallet
        self.derivationpath = derivationpath
    }
    
    public func sign(hexString: String) throws -> String {
        guard let data = Data(hex: hexString).hashPersonalMessage() else {
            throw WalletCoreError.invalidHexString(hexString)
        }
        guard let signedMessage = data.sign(key: privateKey, leadingV: false)?.toHexString().addHexPrefix() else {
            throw WalletCoreError.signingError
        }
        return signedMessage
    }
    
//    public init(address: Address, path: String, network: Network, mnemonic: String)
    /*
    public func sign(tx: Transaction) throws -> String {
        return ""
        try tx.sign(key: privateKey)
        guard let data = tx.serialize(), let string = String(data: data, encoding: .utf8)?.addHexPrefix() else {
            throw WalletCoreError.signingError
        }
        return string
    }
    
    public func sign(_ transaction: Transaction) -> Data {
        return Data()
    }
    
    public func encrypt(cleartext: Data) -> Data {
        return Data()
    }


    */
}
