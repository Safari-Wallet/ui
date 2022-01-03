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
        try await manager.deleteAllWalletsAndBundles(allFiles: true)
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
    
    func testClean() throws {
        // Checks if no files are present and no presets are found
        let path = try URL.sharedContainer().path
        let files = try FileManager.default.contentsOfDirectory(atPath: path)
        XCTAssertEqual(files.count, 0, "found: \(files)")
        
        guard let sharedContainer = UserDefaults(suiteName: APP_GROUP) else {
            XCTFail()
            return
        }
        XCTAssertNil(sharedContainer.object(forKey: AddressBundle.DefaultAddress.key))
    }
    
    func testSaveAddresses() async throws {
        let wallet = try Wallet<PrivateKeyEth1>(mnemonic: mnemonic)
        let addresses = try wallet.generateAddresses(count: 5)
        let id = UUID()
        let bundle = AddressBundle(id: id, walletName: "Ethereum Wallet 1", type: .keystorePassword, network: .ethereum, addresses: addresses)
        try await bundle.save()
        bundle.setDefault()

        let recoveredBundle = try await AddressBundle.load(id: id, network: .ethereum)
        let recoveredAddresses = recoveredBundle.addresses.map{ $0.addressString }
        let addressStrings = addresses.map{ $0.address }
        XCTAssertEqual(addressStrings, recoveredAddresses)
        XCTAssertEqual(recoveredBundle.walletName, "Ethereum Wallet 1")
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

