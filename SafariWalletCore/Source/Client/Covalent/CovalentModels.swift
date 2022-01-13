//
//  File.swift
//  
//
//  Created by Tassilo von Gerlach on 11/6/21.
//

import Foundation
import MEWwalletKit

public enum Covalent {
    
    public struct Response<D: Codable>: Codable {
        let data: D
        let error: Bool
        let error_message: String?
        let error_code: Int?
    }
    
    public struct GetTransactionsResponseData: Codable {
        let address: String
        
        //Leaving these are strings for now since iso8601 decoding fails
        //Covalent also don't spcifiy why date format is expected
        let updated_at: String
        let next_update_at: String
        
        let quote_currency: String
        let chain_id: Int
        let items: [Transaction]
    }
    
    public struct LogEvent: Codable {
        public let block_signed_at: Date
        public let block_height: Int
        public let tx_offset: Int
        public let log_offset: Int
        public let tx_hash: String
    }
    
    public struct Transaction: Codable, Identifiable {
        
        public static func == (lhs: Covalent.Transaction, rhs: Covalent.Transaction) -> Bool {
            return lhs.id == rhs.id
        }
        
        public var id: String {
            return tx_hash
        }
        
        public let block_signed_at: Date
        public let block_height: Int
        public let tx_hash: String
        public let tx_offset: Int?
        public let successful: Bool?
        public let from_address: Address
        public let from_address_label: String?
        public let to_address: Address?
        public let to_address_label: String?
        public let value: String?
        public let value_quote: Double?
        public let gas_offered: Int?
        public let gas_spent: Int?
        public let gas_price: Int?
        public let gas_quote: Double?
        public let gas_quote_rate: Double?
        public let log_events: [LogEvent]
        
    }
    
}
