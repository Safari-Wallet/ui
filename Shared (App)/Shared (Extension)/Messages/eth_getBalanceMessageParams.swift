//
//  eth_getBalanceMessageParams.swift
//  Wallet
//
//  Created by Jamie Rumbelow on 15/01/2022.
//

import Foundation
import SafariWalletCore
import MEWwalletKit

struct eth_getBalanceMessageParams: NativeMessageParams {
    let address: Address
    let block: Block
    
    func execute(with userSettings: UserSettings) async throws -> Any {
        let providerAPI = ProviderAPI(delegate: userSettings)
        return try await providerAPI.parseMessage(method: "eth_getBalance", params: [self.address, self.block])
    }
    
    private enum CodingKeys: CodingKey {
        case address
        case block
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        address = try container.decode(Address.self, forKey: .address)
        if let block = try container.decodeIfPresent(Block.self, forKey: .block) {
            self.block = block
        } else {
            self.block = .latest
        }
    }
}
