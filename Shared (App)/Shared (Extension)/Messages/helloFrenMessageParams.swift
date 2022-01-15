//
//  helloFrenMessageParams.swift
//  Wallet
//
//  Created by Jamie Rumbelow on 15/01/2022.
//

import Foundation

struct helloFrenMessageParams: NativeMessageParams {
    let foo: String
    let bar: Int
    let wagmi: Bool?
    
    func execute(with userSettings: UserSettings) async throws -> Any {
        if let wagmi = self.wagmi {
            return wagmi ? "wagmi" : "ngmi"
        }
        return "ngmi"
    }
}
