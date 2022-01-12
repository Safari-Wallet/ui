//
//  Address.swift
//  Wallet
//
//  Created by Ronald Mannak on 10/28/21.
//

import Foundation
import MEWwalletKit

extension MEWwalletKit.Address: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.address)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        self.init(raw: string)
    }
}
