//
//  SettingsView.swift
//  Wallet
//
//  Created by Ronald Mannak on 11/5/21.
//

import SwiftUI
import MEWwalletKit
import SafariWalletCore

struct SettingsView: View {
    
    @StateObject var viewModel = AccountSelectionViewModel()
            
    var body: some View {
    
        Form {
            if let addressBundles = viewModel.bundles, addressBundles.count > 0 {
                // MARK: - Wallet selection
                Section(header: Text("Wallet")) {
                    Picker("HD Wallets", selection: $viewModel.bundleIndex) {
                        ForEach(0 ..< addressBundles.count) { i in
                            Text(addressBundles[i].walletName ?? "Wallet \(i + 1)")
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.inline)
                }
                
                // MARK: - Accounts selection
                Section(header: Text("Accounts")) {
                    
                    if let bundle = viewModel.defaultBundle() {
                        Picker("Accounts", selection: $viewModel.addressIndex) {
                            ForEach(0 ..<  bundle.addresses.count) { i in
                                let address = bundle.addresses[i]
                                Text(address.ensName ?? address.addressString)
                            }
                        }
                        .labelsHidden()
                        .pickerStyle(.inline)
                    }
                }
            }
                       
            // MARK: - Network selection
            Section(header: Text("Network")) {
                Picker(selection: $viewModel.networkIndex, label: Text("")) {
                    ForEach(viewModel.networks.indices) { i in
                        Text(viewModel.networks[i]).tag(i)
                    }
                }
                .labelsHidden()
                .pickerStyle(.inline)
            }
        }
        .onDisappear {
            viewModel.setDefault()
        }
        .task {
            await viewModel.setup()
        }
    }
    
}

extension SettingsView {
    
    @MainActor
    class AccountSelectionViewModel: ObservableObject {
        
        @Published var bundleIndex: Int = 0 {
            didSet {
                guard let bundle = self.bundles?[bundleIndex] else {
                    return
                }
                self.addressIndex = bundle.defaultAddressIndex
            }
        }
        @Published var addressIndex: Int = 0 {
            didSet {
                guard let bundle = self.bundles?[bundleIndex], addressIndex < bundle.addresses.count else {
                    return
                }
                bundle.defaultAddressIndex = addressIndex
            }
        }
        @Published var networkIndex: Int = 0 {
            didSet {
                guard oldValue != networkIndex else { return }
                Task {
                    let network: Network
                    if networkIndex == 0 {
                        network = .ethereum
                    } else {
                        network = .ropsten
                    }
                    await change(network: network)
                }
            }
        }
        
        var bundles: [AddressBundle]?
        var addresses: [AddressItem]?
        let networks: [String] = ["Mainnet", "Ropsten"]
        
        func setup() async {
            do {
                let defaultBundle = try await AddressBundle.loadDefault()
                let bundles = try await AddressBundle.loadAddressBundles(network: defaultBundle.network).filter{ $0.addresses.count > 0 }
                guard bundles.count > 0, let bundleIndex = bundles.firstIndex(of: defaultBundle) else {
                    return
                }
                                
                self.bundles = bundles
                self.bundleIndex = bundleIndex
                self.addresses = defaultBundle.addresses
                self.addressIndex = defaultBundle.defaultAddressIndex
                if case .ethereum = defaultBundle.network  {
                    networkIndex = 0
                } else {
                    networkIndex = 1
                }
            } catch {
                reset()
                return
            }
        }
        
        func change(network: Network) async {
            do {
                let bundles = try await AddressBundle.loadAddressBundles(network: network).filter{ $0.addresses.count > 0 }
                guard bundles.count > 0 else {
                    throw WalletError.noAddressBundles
                }
                self.bundles = bundles
                self.addresses = bundles[0].addresses
                bundleIndex = 0
                addressIndex = 0
                if case .ethereum = network  {
                    networkIndex = 0
                } else {
                    networkIndex = 1
                }
            } catch {
                await setup()
                return
            }
        }
        
        func reset() {
            self.bundles = nil
            self.addresses = nil
        }
        
        func defaultBundle() -> AddressBundle? {
            guard let bundles = bundles, bundleIndex < bundles.count else {
                return nil
            }
            return bundles[bundleIndex]
        }
        
        func setDefault() {
            guard let bundles = self.bundles, bundleIndex < bundles.count, addressIndex < bundles[bundleIndex].addresses.count else {
                return
            }
            let defaultBundle = bundles[bundleIndex]
            defaultBundle.defaultAddressIndex = addressIndex
            defaultBundle.setDefault()
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
