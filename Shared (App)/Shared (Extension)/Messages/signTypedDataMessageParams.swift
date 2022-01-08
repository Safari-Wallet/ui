//
//  eth_getBalanceMessageParams.swift
//  Wallet
//
//  Created by Jamie Rumbelow on 15/01/2022.
//

import Foundation
import SafariWalletCore
import MEWwalletKit

enum EthSignTypedDataVersion: String, Codable {
    case v3 = "v3"
    case v4 = "v4"
}

struct signTypedDataMessageParams: NativeMessageParams {
    let version: EthSignTypedDataVersion
    let address: Address
    let data: String
    
    func execute(with userSettings: UserSettings) async throws -> Any {
        let providerAPI = ProviderAPI(delegate: userSettings)
        return try await providerAPI.parseMessage(
            method: version == .v4 ? "eth_signTypedData_v4" : "eth_signTypedData_v3",
            params: [self.address.address, self.data]
        )
    }
    
    private enum CodingKeys: CodingKey {
        case version
        case address
        case data
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        version = try container.decode(EthSignTypedDataVersion.self, forKey: .version)
        address = try container.decode(Address.self, forKey: .address)
        data = try container.decode(String.self, forKey: .data)
    }
}
