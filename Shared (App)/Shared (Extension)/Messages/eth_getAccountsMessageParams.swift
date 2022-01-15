//
//  eth_getAccountsMessageParams.swift
//  Wallet
//
//  Created by Jamie Rumbelow on 15/01/2022.
//

import Foundation
import SafariWalletCore

struct eth_getAccountsMessageParams: NativeMessageParams {
    func execute(with userSettings: UserSettings) async throws -> Any {
        let providerAPI = ProviderAPI(delegate: userSettings)
        return try await providerAPI.parseMessage(method: "eth_getAccounts", params: nil)
    }
}
