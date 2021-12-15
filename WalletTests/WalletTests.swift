//
//  WalletTests.swift
//  WalletTests
//
//  Created by Ronald Mannak on 10/10/21.
//

import XCTest
import SafariWalletCore
import MEWwalletKit
@testable import Safari_Wallet

class WalletTests: XCTestCase {
    
    let mnemonic = "abandon amount liar amount expire adjust cage candy arch gather drum buyer"
    let mnemonic2 = "all all all all all all all all all all all all"
    let password = "password123"
    var manager: WalletManager!

    override func setUp() async throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        self.manager = WalletManager()
        try await manager.deleteAllWalletsAndBundles()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
//        XCTFail()
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testSaveAddresses() async throws {
        let wallet = try Wallet<PrivateKeyEth1>(mnemonic: mnemonic)
        let addresses = try wallet.generateAddresses(count: 5)
        let id = UUID()
        let bundle = AddressBundle(id: id, type: .keystorePassword, network: .ethereum, addresses: addresses)
        try await bundle.save()
        let recoveredAddresses = try await AddressBundle.loadAddressBundle(id: id, network: .ethereum).addresses.map{ $0.address }
        XCTAssertEqual(addresses, recoveredAddresses)
    }
    
    func testWalletEncryptionRoundtrip() async throws {
        let passwordData = password.data(using: .utf8)!
        let mnemonicData = mnemonic.data(using: .utf8)!
        let keystore = try await KeystoreV3(privateKey: mnemonicData, passwordData: passwordData)
        let decoded = try await keystore.getDecryptedKeystore(passwordData: passwordData)
        XCTAssertEqual(mnemonicData, decoded)
    }
    
    func testWalletFileRoundtrip() async throws {
        
        let bip39 = try BIP39(mnemonic: mnemonic)
        let keystore = try await KeystoreV3(bip39: bip39, password: password)
        let id = UUID()
        try await keystore.save(name: id.uuidString)
        let restoredWallet = try await KeystoreV3.load(name: id.uuidString, password: password)
        XCTAssertEqual(bip39.mnemonic, restoredWallet.mnemonic)
    }
}

