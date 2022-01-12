//
//  Wei.swift
//  Balance
//
//  Created by Ronald Mannak on 10/26/21.
//

import Foundation
import BigInt

public typealias GWei = Decimal
public typealias Ether = Decimal

public struct Wei {

    // NOTE: calculate wei by 10^18
    static var gWeiInWei: Decimal { pow(Decimal(10), 9) }
    static var etherInWei: Decimal { pow(Decimal(10), 18) }

    private (set) var value: BigInt
    
    public var hexString: String {
        value.description.toHexString().addHexPrefix()
    }

    // MARK: - Conversions
    
    /// Convert Wei  to Gwei (Decimal)
    public var gWeiValue: GWei? {
        guard let decimalWei = Decimal(string: self.description) else { return nil }
        return decimalWei / Wei.gWeiInWei
    }
    
    /// Convert Wei to Ether (Decimal)
    public var etherValue: Ether? {
        guard let decimalWei = Decimal(string: self.description) else { return nil }
        return decimalWei / Wei.etherInWei
    }
    
    ///Convert Wei to Tokens balance
    public func toToken(decimals: Int) -> Ether? {
        guard let  decimalWei = Decimal(string: self.description) else { return nil }
        return decimalWei / pow(10, decimals)
    }
}

extension Wei {
    
    public init?(hexString: String) {
        guard let value = BigInt(hex: hexString.stripHexPrefix()) else { return nil }
        self.value = value
    }
    
    public init?(_ string: String) {
        guard let value = BigInt(string, radix: 10) else { return nil }
        self.value = value
    }
    
    public init?(_ decimal: Decimal) {
        guard let value = BigInt(decimal.description, radix: 10) else { return nil }
        self.value = value
    }
    
    // FIXME: If Gwei is a float, this returns nil
//    public init?(gwei: GWei) {
//        guard let amount = BigInt(gwei.description, radix: 10), let wei = BigInt(Wei.gWeiInWei.description, radix: 10) else { return nil }
//        self.value = amount * wei
//    }
    
    public init?(ether: Ether) {
        guard let amount = BigInt(ether.description, radix: 10), let wei = BigInt(Wei.etherInWei.description, radix: 10) else { return nil }
        self.value = amount * wei
    }
}

extension Wei: CustomStringConvertible {
    public var description: String {
        return self.value.description
    }
}

extension Wei: Codable {

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.hexString)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        if string.hasPrefix("0x") {
            guard let intValue = BigInt(hex: string.stripHexPrefix()) else { throw WalletCoreError.unexpectedResponse(string) }
            self.init(value: intValue)
        } else {
            guard let intValue = BigInt(string, radix: 10) else { throw WalletCoreError.unexpectedResponse(string) }
            self.init(value: intValue)
        }
    }
}

extension Wei: Equatable {
    public static func ==(lhs: Wei, rhs: Wei) -> Bool {
        return lhs.value == rhs.value
    }
}

extension Wei: Comparable {
    public static func <(lhs: Wei, rhs: Wei) -> Bool {
        return lhs.value < rhs.value
    }
}

extension Wei: SignedNumeric {
    
    public typealias Magnitude = BigInt
    public typealias IntegerLiteralType = Int
    
    public init?<T>(exactly source: T) where T : BinaryInteger {
        self.value = BigInt(source)
    }
    
    public init(integerLiteral value: Int) {
        self.value = BigInt(value)
    }
    
    public var magnitude: BigInt {
        return BigInt(self.value.magnitude)
    }
    
    public static func *= (lhs: inout Wei, rhs: Wei) {
        return lhs.value = lhs.value * rhs.value
    }

    public static func + (lhs: Wei, rhs: Wei) -> Wei {
        return Wei(value: lhs.value + rhs.value)
    }

    public static func - (lhs: Wei, rhs: Wei) -> Wei {
        return Wei(value: lhs.value - rhs.value)
    }

    public static func * (lhs: Wei, rhs: Wei) -> Wei {
        return Wei(value: lhs.value * rhs.value)
    }
}
