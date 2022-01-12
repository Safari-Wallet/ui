//
//  WalletCoreError.swift
//  
//
//  Created by Ronald Mannak on 10/31/21.
//

import Foundation

public enum WalletCoreError: Error {
    case unexpectedResponse(String)
    case noMethod
    case unknownMethod(String)
    case invalidParams
    case noParameters
    case addressGenerationError
    case notImplemented(String)
    case noClient
    case encodingError
    case decodingError
    case signingError
    case invalidHexString(String)
}

extension WalletCoreError: LocalizedError {
    
    /// A localized message describing what error occurred.
    public var errorDescription: String? {
        switch self {
        case .unexpectedResponse(let response):
            return "Unexpected response: \(response)"
        case .noMethod:
            return "Missing method"
        case .unknownMethod(let method):
            return "Unsupported method: \(method)"
        case .invalidParams:
            return "Invalid parameters"
        case .noParameters:
            return "No parameters"
        case .addressGenerationError:
            return "Unable to generate address="
        case .notImplemented(let method):
            return "Method not implemented: \(method)"
        case .noClient:
            return "No network client set"
        case .encodingError:
            return "Encoding error"
        case .decodingError:
            return "Decoding error"
        case .signingError:
            return "Singing error"
        case .invalidHexString(let string):
            return "Expected hex string: \(string)"
        }
    }

    /// A localized message describing the reason for the failure.
    public var failureReason: String? { return nil }

    /// A localized message describing how one might recover from the failure.
    public var recoverySuggestion: String? { return nil }

    /// A localized message providing "help" text if the user requests help.
    public var helpAnchor: String? { return nil }
}

// TODO: If the JS code needs to parse error messages, we need to add error codes
//extension WalletCoreError: CustomNSError {
//
//    public var errorCode: Int {
//            switch self {
//
//            }
//        }
//}
