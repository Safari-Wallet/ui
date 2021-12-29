//
//  WalletApp.swift
//  Wallet
//
//  Created by Ronald Mannak on 10/9/21.
//

import Foundation

import SwiftUI

@main
struct WalletApp: App {
    
    @StateObject var manager = WalletManager()
    @State private var shouldPresentOnboarding = false
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView(isOnBoardingPresented: $shouldPresentOnboarding)
                .task {
                    try? await manager.setup()
                    print("bundles: \(manager.addressBundles?.count ?? -1)")
                    guard let bundles = manager.addressBundles, bundles.count > 0 else {
                        self.shouldPresentOnboarding = true
                        return
                    }
                }
//                .task {
//                    do {
//                        // If the app has no address bundles, show Restore or Create Wallet view
//
////                        assert(Thread.isMainThread)
//                        if try await hasAccounts() == false {
//                            shouldPresentOnboarding = true
//                        }
////                        shouldPresentOnboarding = try await !hasAccounts()
//                    } catch {
//                        print(error.localizedDescription)
//                    }
//
//                }
                .onOpenURL { url in handle(url: url) }
                .environmentObject(manager)
        }
        
    }
    
    func valueForKey(_ key: String, in items: [URLQueryItem]?) -> String? {
        guard let items = items else { return nil }
        for item in items {
            if item.name == key {
                return item.value
            }
        }
        return nil
    }
}

// MARK: - Onboarding

extension WalletApp {
    
//    @MainActor
//    func hasAccounts() async throws -> Bool {
//        assert(Thread.isMainThread)
//        try await manager.setup()
//        guard let bundles = manager.addressBundles, bundles.count > 0 else { return false }
//        return true
//    }
}

// MARK: - Handle open URL

extension WalletApp {
    
    // try: safari-wallet://sign?tx=0x342af423&y=2
    func handle(url: URL) {
        
        guard let host = url.host, let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            print("Invalid URL path missing")
            return
        }
        let params = components.queryItems

        switch host {
        case "sign":
            guard let value = valueForKey("tx", in: params) else {
                print("")
                return
            }
            print("signing tx \(value)")
            // Sign view
            return

//                    case "openwallet":
        default:
            print("Invalid url: \(url)")
        }

    }
}
