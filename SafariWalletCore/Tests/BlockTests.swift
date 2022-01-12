//
//  BlockTests.swift
//  
//
//  Created by Stefano on 12.11.21.
//

import XCTest
@testable import SafariWalletCore

class BlockTests: XCTestCase {

    func testHexBlockNumberReturnsIntValue() {
        let hexBlockNumber = "0xCF6BAB"
        let block = Block(rawValue: hexBlockNumber)
        XCTAssertEqual(block.intValue, 13593515)
    }
    
    func testHexBlockNumberReturnsHexValue() {
        let hexBlockNumber = "0xCF6BAB"
        let block = Block(rawValue: hexBlockNumber)
        XCTAssertEqual(block.stringValue, hexBlockNumber)
    }
    
    func testIntBlockNumberReturnsIntValue() {
        let intBlockNumber = 13593515
        let block = Block(rawValue: intBlockNumber)
        XCTAssertEqual(block.intValue, intBlockNumber)
    }
    
    func testIntBlockNumberReturnsHexValue() {
        let intBlockNumber = 13593515
        let hexBlockNumber = "0xCF6BAB"
        let block = Block(rawValue: intBlockNumber)
        XCTAssertEqual(block.stringValue, hexBlockNumber)
    }
}
