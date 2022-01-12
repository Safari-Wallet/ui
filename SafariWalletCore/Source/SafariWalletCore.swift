//
//  SafariWalletCore.swift
//
//
//  Created by Ronald Mannak on 10/30/21.
//

import MEWwalletKit

public protocol SafariWalletCoreDelegate {
    func addresses() -> [String]?
    func account(address: String, password: String?) async throws -> Account
    func client() -> EthereumClient?
    func currentNetwork() -> Network
}

public class SafariWalletCore {
    
//    public static let shared = SafariWalletCore()
//
//    public var delegate: SafariWalletCoreDelegate? = nil
//
//    private init() { }
}
