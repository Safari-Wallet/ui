//
//  WalletApp.swift
//  Wallet
//
//  Created by Ronald Mannak on 10/9/21.
//

import Foundation

import SwiftUI
import SafariWalletCore

@main
struct WalletApp: App {
    
    @StateObject var manager = WalletManager()
    @State private var shouldPresentOnboarding = false
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    let userDefaultPublisher = NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)
    
    var body: some Scene {
        WindowGroup {
            ContentView(isOnBoardingPresented: $shouldPresentOnboarding)
                .task {
                    do {
                        try await manager.setup()
                    } catch {
                        print("Unable to load default wallet: \(error.localizedDescription)")
                        assert(Thread.isMainThread)
                        shouldPresentOnboarding = true
                    }
                }
                .onAppear{
                    do {
                        try migrate()
                    } catch {
                        print("Error migrating: \(error)")
                    }
                }
                .onOpenURL { url in handle(url: url) }
                .environmentObject(manager)
                .onReceive(userDefaultPublisher) { output in
//                    print("⚠️ UserDefaults changed")
                    Task {
                        do {
                            try await manager.setup()
                        } catch {
                            print("Error manager setup: \(error.localizedDescription)")
                        }
                    }
                }
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

// MARK: - App version migration

extension WalletApp {
    
    func migrate() throws {
        guard let sharedContainer = UserDefaults(suiteName: APP_GROUP) else { throw WalletError.invalidAppGroupIdentifier(APP_GROUP) }
        let build = sharedContainer.string(forKey: "build")
        if build != Bundle.main.build {
            sharedContainer.set(Bundle.main.build, forKey: "build")
            sharedContainer.synchronize()
        }
    }
    
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
