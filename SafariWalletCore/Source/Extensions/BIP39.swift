//
//  BIP39.swift
//  
//
//  Created by Ronald Mannak on 12/6/21.
//

import Foundation
import MEWwalletKit

extension BIP39 {
    
    public convenience init(mnemonic: String) throws {
        self.init(mnemonic: mnemonic.components(separatedBy: " "))
    }
}

// MARK: - Recovery phrase shuffle and
extension BIP39 {
      
    public func shuffle() -> [String]? {
        return self.mnemonic?.shuffled()
    }
    
    public func isEqual(to phrase: [String]) -> Bool {
        guard let mnemonic = self.mnemonic else { return false }
        return mnemonic == phrase
    }    
}
