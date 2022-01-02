//
//  WalletError.swift
//  Wallet
//
//  Created by Ronald Mannak on 10/8/21.
//

import Foundation

enum WalletError: Error {
    case invalidAppGroupIdentifier(String)
    case invalidInput(String?)
    case invalidPassword
    case wrongPassword
    case passwordRequired
    case addressNotFound(String)
    case addressGenerationError
    case AddressFileError
    case seedError
    case noDefaultWalletSet
    case noDefaultAddressSet
    case noAddressBundles
    case unexpectedResponse(String)
    case noMethod
    case errorOpeningKeyStore(String)
    case viewOnly
    case notImplemented
    case outOfBounds
    case fileNotFound(String)
}

extension WalletError: LocalizedError {
    
    /// A localized message describing what error occurred.
    var errorDescription: String? {
        switch self {
        case .invalidAppGroupIdentifier (let group):
            return "Invalid App Group identifier: \(group)"
        case .invalidInput (let input):
            return input == nil ? "Invalid input" : "Invalid input: \(input!)"
        case .invalidPassword:
            return "Invalid password"
        case .wrongPassword:
            return "Wrong password"
        case .passwordRequired:
            return "Password required"
        case .addressNotFound(let address):
            return "No account found for address \(address)"
        case .addressGenerationError:
            return "Error generating address"
        case .AddressFileError:
            return "Error opening address file"
        case .seedError:
            return "Invalid recovery phrase"
        case .noDefaultWalletSet:
            return "No default wallet set"
        case .noDefaultAddressSet:
            return "No default address set"
        case .unexpectedResponse(let response):
            return "Unexpected response: \(response)"
        case .noMethod:
            return "Call with no method"
        case .errorOpeningKeyStore(let name):
            return "Error opening keystore file \(name)"
        case .viewOnly:
            return "This wallet is view-only"
        case .notImplemented:
            return "Method not implemented"
        case .outOfBounds:
            return "Out of bounds"
        case .noAddressBundles:
            return "No address bundles found"
        case .fileNotFound(let file):
            return "File not found: \(file)"
        }
    }

    /// A localized message describing the reason for the failure.
    var failureReason: String? { return nil }

    /// A localized message describing how one might recover from the failure.
    var recoverySuggestion: String? { return nil }

    /// A localized message providing "help" text if the user requests help.
    var helpAnchor: String? { return nil }
}

// TODO: If the JS code needs to parse error messages, we need to add error codes
//extension WalletError: CustomNSError {
//
//    var errorCode: Int {
//            switch self {
//
//            }
//        }
//}
