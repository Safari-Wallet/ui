//
//  File.swift
//  
//
//  Created by Ronald Mannak on 11/8/21.
//

import Foundation
import MEWwalletKit

public struct Call: Codable {    
    let from: Address?
    let to: Address
    let gas: Int? // BigInt?
    let gasPrice: Wei?
    let value: Wei?
    let data: String?
}

public struct CallWrapper: Codable {
    
    let call: Call
    let block: Block

    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(call)
        try container.encode(block)
     }

}
