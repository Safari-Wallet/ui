//
//  Bundle.swift
//  Wallet
//
//  Created by Ronald Mannak on 12/31/21.
//

import Foundation

extension Bundle {
    
    var version: String {
        guard let version = infoDictionary?["CFBundleShortVersionString"] as? String else {
            return "Unknown version"
        }
        return version
    }
    
    var build: String {
        guard let build = infoDictionary?["CFBundleVersion"] as? String else {
            return "Unknown build number"
        }
        return build
    }
        
    var appName: String {
        guard let appName = infoDictionary?["CFBundleName"] as? String else {
            return "App"
        }
        return appName
    }
}
