//
//  AddressBundleType.swift
//  Wallet
//
//  Created by Ronald Mannak on 11/17/21.
//

import Foundation

enum PrivateKeyType {
    case keystorePassword
    case keystoreSecureEnclave
    case viewOnly
    case nanoLedgerX(id: String, bip44: Bool)
    case nanoLedgerS(id: String, bip44: Bool)
    case trezor(id: String)
}

extension PrivateKeyType: Codable {
}
