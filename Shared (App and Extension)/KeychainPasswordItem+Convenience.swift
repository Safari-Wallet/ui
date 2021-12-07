//
//  KeychainPasswordItem.swift
//  Wallet
//
//  Created by Ronald Mannak on 12/2/21.
//

import Foundation

extension KeychainPasswordItem {
    
    
    /// Convenience method to store password in keychain
    /// - Parameters:
    ///   - password: The password to be stored
    ///   - account: UUIDstring of the keystore file the password belongs to
    ///   - reusableDuration: Time password can be used without FaceID/TouchID verification. Default is 1200 seconds (20 minutes)
    static func store(password: String, account: String, reusableDuration: TimeInterval = 1200) async throws {
        let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName,
                                                account: account,
                                                accessGroup: KeychainConfiguration.accessGroup)
        try passwordItem.savePassword(password, userPresence: true, reusableDuration: reusableDuration)
    }
}
