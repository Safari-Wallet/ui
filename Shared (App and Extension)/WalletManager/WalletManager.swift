//
//  WalletManager.swift
//  Wallet
//
//  Created by Ronald Mannak on 10/9/21.
//

import Foundation
import MEWwalletKit
import SafariWalletCore

//@MainActor
final class WalletManager: ObservableObject {
    
    //@MainActor
    @Published var address: AddressItem?
    
    @Published var network: Network = .ethereum
    
    @MainActor
    func setup() async throws {
        let defaultBundle = try await AddressBundle.loadDefault()
        self.address = defaultBundle.addresses[defaultBundle.defaultAddressIndex]
        self.network = defaultBundle.network
    }
   
}
