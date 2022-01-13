//
//  File.swift
//  
//
//  Created by Ronald Mannak on 11/3/21.
//

import Foundation

extension Encodable {
 
    func asDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw WalletCoreError.unexpectedResponse(String(data: data, encoding: .utf8) ?? "Error decoding data")
        }
        return dictionary
    }
    
    func asArray() throws -> [Any] {
        let data = try JSONEncoder().encode(self)
        guard let array = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [Any] else {
            throw WalletCoreError.unexpectedResponse(String(data: data, encoding: .utf8) ?? "Error decoding data")
        }
        return array
    }
}
