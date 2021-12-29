//
//  SettingsView.swift
//  Wallet
//
//  Created by Ronald Mannak on 11/5/21.
//

import SwiftUI
import MEWwalletKit

struct SettingsView: View {
    
    @EnvironmentObject var manager: WalletManager
    
    private let networks: [String] = ["Mainnet", "Ropsten"]
    @State private var selectedNetworkIndex = 0
    
//    @State private var wallets: [String] = []
//    @State private var selectedWalletIndex = manager.defaultAddressBundleIndex
    
//    @State private var addresses: [String] = []
//    @State private var selectedAddressIndex = 0
        
    var body: some View {

        Form {
            let _ = print("⚠️ # of bundles: \(manager.addressBundles?.count ?? -1)")
            if let addressBundles = manager.addressBundles, addressBundles.count > 0 {
                let _ = print("⚠️ found address bundles")
                // MARK: - Wallet selection
                Section(header: Text("Wallet")) {
                    Picker("HD Wallets", selection: $manager.defaultAddressBundleIndex) {
                        ForEach(0 ..< addressBundles.count) { i in
                            Text(addressBundles[i].walletName ?? "Wallet \(i)")
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.inline)
//                    .onChange(of: selectedWalletIndex) { tag in
//                        Task {
//                            try? await manager.setDefaultWallet(addressBundles[tag])
////                            await reloadWallet()
//                        }
//                    }
                }
                
                // MARK: - Accounts selection
                Section(header: Text("Accounts")) {
                        
//                        Picker("Accounts", selection: manager.$defaultAddressBundleIndex) {
//                            ForEach(0 ..< addressBundles.count) { i in
//                                Text(addressBundles[i].walletName)
//                            }
//                        }
//                        .labelsHidden()
//                        .pickerStyle(.inline)
//                        .onChange(of: selectedWalletIndex) { tag in
//                            Task {
//                                try? await manager.setDefaultWallet(addressBundles[tag])
//                                await reloadWallet()
//                            }
//                        }
                }
            }            
//            .task {
//                await self.reloadWallet(firstPass: true)
//            }
        
            // MARK: - Network selection
            Section(header: Text("Network")) {
                Picker(selection: $selectedNetworkIndex, label: Text("")) {
                    ForEach(networks.indices) { i in
                        Text(networks[i]).tag(i)
                    }
                }
                .labelsHidden()
                .pickerStyle(.inline)
                .onChange(of: selectedNetworkIndex) { tag in
                    Task {
                        if tag == 1 {
                            try await manager.setup(network: .ropsten)
                        } else {
                            try await manager.setup(network: .ethereum)
                        }
                    }
                }
                .onAppear {
                    if case .ropsten = manager.defaultNetwork  {
                        selectedNetworkIndex = 1
                    } else {
                        selectedNetworkIndex = 0
                    }
                    
                }
            }
        }
    }
    
//    func reloadWallet(firstPass: Bool = false) async {
//        guard let defaultWallet = manager.defaultWallet,
//              let wallets = try? manager.listWalletFiles(),
//              let addresses = try? await manager.loadAddresses(name: defaultWallet),
//              let defaultAddress = manager.defaultAddress,
//              let selectedWalletIndex = wallets.firstIndex(of: defaultWallet),
//              let selectedAddressIndex = addresses.firstIndex(of: defaultAddress)
//        else {
//            print("Error reloading wallet")
//            return
//        }
//        self.wallets = wallets
//        self.addresses = addresses
//        self.selectedWalletIndex = selectedWalletIndex
//        self.selectedAddressIndex = selectedAddressIndex
//    }
    
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
