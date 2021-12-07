//
//  AddressItem.swift
//  Wallet
//
//  Created by Ronald Mannak on 11/17/21.
//

import Foundation
import SwiftUI
import MEWwalletKit
import SafariWalletCore

class AddressItem: Codable, Identifiable, ObservableObject {
    
    let id: Int
    
    private (set) var ensName: String?
    
    /// Human readable, end-user defined name
    var accountName: String?
    
    let bundleUUID: UUID
    
    let address: Address
    
    let derivationIndex: Int
        
    enum CodingKeys: CodingKey {
        case ensName
        case accountName
        case bundleUUID
        case address
        case derivationIndex
    }
    
    init(address: Address, derivationIndex: Int, bundleUUID: UUID, accountName: String?) {
        self.id = derivationIndex
        self.accountName = accountName
        self.bundleUUID = bundleUUID
        self.address = address
        self.derivationIndex = derivationIndex
    }
    
    func fetchENSname() async {
        // TODO: add ENS support
    }

    // MARK: - Codable
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        ensName = try container.decode(String?.self, forKey: .ensName)
        accountName = try container.decode(String?.self, forKey: .accountName)
        bundleUUID = try container.decode(UUID.self, forKey: .accountName)
        address = try container.decode(Address.self, forKey: .address)
        derivationIndex = try container.decode(Int.self, forKey: .derivationIndex)
        id = derivationIndex
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(ensName, forKey: .ensName)
        try container.encode(accountName, forKey: .accountName)
        try container.encode(bundleUUID, forKey: .bundleUUID)
        try container.encode(address, forKey: .address)
        try container.encode(derivationIndex, forKey: .derivationIndex)
    }
}



