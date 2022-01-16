//
//  ENSService.swift
//  Wallet (iOS)
//
//  Created by Stefano on 14.01.22.
//

import Foundation
import MEWwalletKit
import SafariWalletCore

protocol ENSResolvable {
    func resolve(address: RawAddress) async throws -> String
}

protocol ENSReverseResolvable {
    func resolve(ens: String) async throws -> RawAddress
}
