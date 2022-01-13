//
//  AlchemyTests.swift
//  BalanceTests
//
//  Created by Ronald Mannak on 10/26/21.
//

import XCTest
import MEWwalletKit
import BigInt
@testable import SafariWalletCore

class AlchemyTests: XCTestCase {
    
    var ropstenClient: AlchemyClient!
    var mainnetClient: AlchemyClient!
//    var account: Account!
    let uniswapTokenContract = Address(address: "0x1f9840a85d5af5bf1d1762f925bdaddc4201f984")

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        super.setUp()
        self.ropstenClient = AlchemyClient(network: .ropsten, key: "<ALCHEMY ROPSTEN KEY HERE>")
        self.mainnetClient = AlchemyClient(key: "<ALCHEMY MAINNET KEY HERE>")
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

    func testTokenAllowance() async throws {
        
        // This is a random Ethereum address that recently had approved tokens on Uniswap
        // Since Uniswap always allows the maxInt amount, the allowance is always the same
        let tokenContract = Address(address: "0x1f9840a85d5af5bf1d1762f925bdaddc4201f984")!
        let owner = Address(address: "0x99a16cec9e0c5f3421da53b83b6649a85b3f4054")!
        let spender = Address(address: "0x2faf487a4414fe77e2327f0bf4ae2a264a776ad2")!
        
        let allowance = try await mainnetClient.alchemyTokenAllowance(tokenContract: tokenContract, owner: owner, spender: spender)
        XCTAssertEqual(allowance, Wei("79228162514264337593543950335")!) // maxValue
        XCTAssertEqual(allowance.description, "79228162514264337593543950335")
        print("allowance: \(allowance)")
    }
    
    func testEth_maxPriorityFeePerGas() async throws {
        let fee = try await mainnetClient.maxPriorityFeePerGas()
        XCTAssertGreaterThan(fee, 0)
    }
}
