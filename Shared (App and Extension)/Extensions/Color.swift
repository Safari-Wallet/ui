//
//  Color.swift
//  Wallet
//
//  Created by Ronald Mannak on 1/7/22.
//

import Foundation
import SwiftUI

extension Color {
    
    
    /// E.g. Color(hex: 0x000000, alpha: 0.2)
    /// - Parameters:
    ///   - hex: e.g. 0xE7E7EC
    ///   - alpha: e.g. 0.2
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}
