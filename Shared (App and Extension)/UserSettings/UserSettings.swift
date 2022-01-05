//
//  UserSettings.swift
//  Wallet
//
//  Created by Ronald Mannak on 10/9/21.
//

import Foundation
import MEWwalletKit
import SafariWalletCore

final class UserSettings: ObservableObject {
    
    @Published private (set) var address: AddressItem?
    
    @Published private (set) var network: Network = .ethereum
    
    @Published var bundle: AddressBundle? {
        didSet {
            // Set address and network properties
            guard let bundle = bundle,
                  bundle.bundleExists else {
                self.address = nil
                self.network = .ethereum
                sharedContainer.removeObject(forKey: UserSettings.bundleKey)
                return
            }
            self.address = bundle.addresses[bundle.defaultAddressIndex]
            self.network = bundle.network
            guard let data = try? JSONEncoder().encode(bundle) else {
                return
            }
            sharedContainer.set(data, forKey: UserSettings.bundleKey)
            sharedContainer.synchronize()
        }
    }
    
    @Published var devMode: Bool {
        didSet {
            sharedContainer.set(devMode, forKey: UserSettings.devModeKey)
            sharedContainer.synchronize()
        }
    }
    
    let sharedContainer = UserDefaults(suiteName: APP_GROUP)!
    
    static let bundleKey = "DefaultBundle"
    static let devModeKey = "DevMode"
    
    init() {        
        // Load default address
        let decoder = JSONDecoder()
        if let data = sharedContainer.object(forKey: UserSettings.bundleKey) as? Data,
           let bundle = try? decoder.decode(AddressBundle.self, from: data) {
            self.bundle = bundle
            self.address = bundle.addresses[bundle.defaultAddressIndex]
            self.network = bundle.network
        }
        
        // Load dev mode setting
        if let _ = sharedContainer.object(forKey: UserSettings.devModeKey) {
            self.devMode = sharedContainer.bool(forKey: UserSettings.devModeKey)
        } else {
            // "DevMode" key doesn't exist in user defaults
            self.devMode = false
        }
    }
   
}
