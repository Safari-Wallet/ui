//
//  String.swift
//  Wallet
//
//  Created by Ronald Mannak on 10/10/21.
//

import Foundation

extension String {

    func appendPathExtension(_ fileExt: String) throws -> String {
        
        guard let name = (self as NSString).appendingPathExtension(fileExt) else {
            throw WalletError.invalidInput(fileExt)
        }
        return name
    }
    
    var pathExtension: String {
        return (self as NSString).pathExtension
    }
    
    func deletingPathExtension() -> String {
        (self as NSString).deletingPathExtension
    }
    
    func withoutHexPrefix() -> String {
        if self.hasPrefix("0x") {
            let index = self.index(self.startIndex, offsetBy: 2)
            return String(self[index...])
        }
        return self
    }
    
    func withHexPrefix() -> String {
        if !self.hasPrefix("0x") {
            return "0x" + self
        }
        return self
    }
}
