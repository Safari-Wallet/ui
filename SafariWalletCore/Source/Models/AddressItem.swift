//
//  Address.swift
//  Wallet
//
//  Created by Ronald Mannak on 11/17/21.
//

import Foundation
import SwiftUI
import MEWwalletKit

public class AddressItem: Codable, Identifiable, ObservableObject {
    
    public let id: Int
    
    public let addressString: String
    
    private let mewAddress: MEWwalletKit.Address
    
    public private (set) var ensName: String?
    
    /// Human readable, end-user defined name
    public var accountName: String?
    
    public let bundleUUID: UUID
    
    let derivationIndex: Int
           
    public init(address: MEWwalletKit.Address, derivationIndex: Int, bundleUUID: UUID, accountName: String?) {
        self.id = derivationIndex
        self.accountName = accountName
        self.bundleUUID = bundleUUID
        self.addressString = address.address
        self.mewAddress = address
        self.derivationIndex = derivationIndex
    }
    
    public func fetchENSname() async {
        // TODO: add ENS support
    }

    // MARK: - Codable
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        ensName = try container.decode(String?.self, forKey: .ensName)
        accountName = try container.decode(String?.self, forKey: .accountName)
        bundleUUID = try container.decode(UUID.self, forKey: .bundleUUID)
        mewAddress = try container.decode(MEWwalletKit.Address.self, forKey: .mewAddress)
        addressString = try container.decode(String.self, forKey: .address)
        derivationIndex = try container.decode(Int.self, forKey: .derivationIndex)
        id = derivationIndex
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(ensName, forKey: .ensName)
        try container.encode(accountName, forKey: .accountName)
        try container.encode(bundleUUID, forKey: .bundleUUID)
        try container.encode(mewAddress, forKey: .mewAddress)
        try container.encode(addressString, forKey: .address)
        try container.encode(derivationIndex, forKey: .derivationIndex)
    }
    
    public enum CodingKeys: CodingKey {
        case ensName
        case accountName
        case bundleUUID
        case address
        case mewAddress
        case derivationIndex
    }    
}



