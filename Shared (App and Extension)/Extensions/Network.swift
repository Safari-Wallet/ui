//
//  Network.swift
//  Wallet
//
//  Created by Ronald Mannak on 1/5/22.
//

import Foundation
import MEWwalletKit

extension Network: Equatable {
    public static func == (lhs: Network, rhs: Network) -> Bool {
        lhs.name == rhs.name
    }
}
