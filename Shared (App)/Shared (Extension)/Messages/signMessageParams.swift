//
//  eth_getBalanceMessageParams.swift
//  Wallet
//
//  Created by Jamie Rumbelow on 15/01/2022.
//

import Foundation
import SafariWalletCore
import MEWwalletKit

enum SignMethod: String, Codable {
    case eth_sign = "eth_sign"
    case personal_sign = "personal_sign"
    case eth_signTypedData_v3 = "eth_signTypedData_v3"
    case eth_signTypedData_v4 = "eth_signTypedData_v4"
}

struct signMessageParams: NativeMessageParams {
    let method: SignMethod
    let address: Address
    let data: String
    
    func execute(with userSettings: UserSettings) async throws -> Any {
        let providerAPI = ProviderAPI(delegate: userSettings)
        return try await providerAPI.parseMessage(
            method: method.rawValue,
            params: [self.address.address, self.data]
        )
    }
    
    private enum CodingKeys: CodingKey {
        case method
        case address
        case data
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        method = try container.decode(SignMethod.self, forKey: .method)
        address = try container.decode(Address.self, forKey: .address)
        data = try container.decode(String.self, forKey: .data)
    }
}
