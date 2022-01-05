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
    @State var presentNewWalletMenu = false
    @State var presentOnboarding: Bool = false
    @EnvironmentObject var userSettings: UserSettings
            
    var body: some View {
    
        Form {
            if viewModel.bundles.count > 0 {
                // MARK: - Wallet selection
                Section(header: Text("Wallet")) {
                    Picker("HD Wallets", selection: $viewModel.bundleIndex) {
                        ForEach(viewModel.bundles, id: \.id) {  bundle in
                            Text(bundle.walletName ?? "Unnamed wallet")
                        }
//
//                        ForEach(0 ..< addressBundles.count) { i in
//                            Text(addressBundles[i].walletName ?? "Wallet \(i + 1)")
//                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.inline)
                }

                // MARK: - Accounts selection
//                Section(header: Text("Accounts")) {
//
//                    if let bundle = viewModel.defaultBundle() {
//                        Picker("Accounts", selection: $viewModel.addressIndex) {
//                            ForEach(0 ..<  bundle.addresses.count) { i in
//                                let address = bundle.addresses[i]
//                                Text(address.ensName ?? address.addressString)
//                            }
//                        }
//                        .labelsHidden()
//                        .pickerStyle(.inline)
//                    }
//                }
            }
                       
            // MARK: - Network selection
            if userSettings.devMode == true {
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
            
            // MARK: - Developer Mode
            Section(header: Text("Developer Mode")) {
                Toggle("Developer Mode", isOn: $userSettings.devMode)
            }
            
            // MARK: - Add new wallet
            Section(header: Text("Actions")) {
                Button("Add new wallet") {
                    self.presentNewWalletMenu = true
                }
                .confirmationDialog("Add a new wallet", isPresented: $presentNewWalletMenu) {
                    Button("New software wallet") {
                        presentOnboarding = true
                    }
                    Button("Add view-only wallet") {
                        print("Not implemented yet")
                    }
                    Button("Connect Ledger Nano X") {
                        print("Not implemented yet")
                    }
                    Button("Restore wallet") {
                        print("Not implemented yet")
                    }
                }
            }
        }
        .onAppear {
            self.viewModel.userSettings = self.userSettings
        }
        .onDisappear {
            userSettings.bundle = viewModel.bundles[viewModel.bundleIndex]
        }
        .task {
            await viewModel.setup()
        }
        .sheet(isPresented: $presentOnboarding) { OnboardingView(isCancelable: true) }
        .environmentObject(userSettings)
    }        
    
}

extension SettingsView {
    
    @MainActor
    class AccountSelectionViewModel: ObservableObject {
        
        var userSettings: UserSettings?
        
        @Published var bundleIndex: Int = 0 {
            didSet {
                guard bundleIndex < self.bundles.count else { return }
                let bundle = self.bundles[bundleIndex]
                self.addressIndex = bundle.defaultAddressIndex
            }
        }
        
        @Published var addressIndex: Int = 0 {
            didSet {
                let bundle = self.bundles[bundleIndex]
                bundle.defaultAddressIndex = addressIndex
            }
        }
        
        @Published var networkIndex: Int = 0 //{
//            didSet {
//                guard oldValue != networkIndex else { return }
//                Task {
//                    let network: Network
//                    if networkIndex == 0 {
//                        network = .ethereum
//                    } else {
//                        network = .ropsten
//                    }
//                    await change(network: network)
//                }
//            }
//        }
        
        @Published var bundles = [AddressBundle]()
        @Published var addresses = [AddressItem]()
        let networks: [String] = ["Mainnet", "Ropsten"]
                
        @MainActor
        func setup() async {
            do {
                self.bundles = try await AddressBundle.loadAddressBundles(network: userSettings!.network)
                guard let defaultBundle = userSettings!.bundle,
                let bundleIndex = bundles.firstIndex(of: defaultBundle) else {
                    self.bundleIndex = 0
                    if self.bundles.count > 0 {
                        self.addressIndex = self.bundles[bundleIndex].defaultAddressIndex
                    }
                    return
                }
                                     
                self.bundleIndex = bundleIndex
                self.addressIndex = defaultBundle.defaultAddressIndex
                self.addresses = defaultBundle.addresses
                        
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
//            do {
//                let bundles = try await AddressBundle.loadAddressBundles(network: network).filter{ $0.addresses.count > 0 }
//                guard bundles.count > 0 else {
//                    throw WalletError.noAddressBundles
//                }
//                self.bundles = bundles
//                self.addresses = bundles[0].addresses
//                bundleIndex = 0
//                addressIndex = 0
//                if case .ethereum = network  {
//                    networkIndex = 0
//                } else {
//                    networkIndex = 1
//                }
//            } catch {
//                await setup()
//                return
//            }
        }
        
        func reset() {
            self.bundles = [AddressBundle]()
            self.addresses = [AddressItem]()
        }
        
//        func defaultBundle() -> AddressBundle? {
//            guard let bundles = bundles, bundleIndex < bundles.count else {
//                return nil
//            }
//            return bundles[bundleIndex]
//        }
        
//        func setDefault() {
//            guard let bundles = self.bundles, bundleIndex < bundles.count, addressIndex < bundles[bundleIndex].addresses.count else {
//                return
//            }
//            let defaultBundle = bundles[bundleIndex]
//            defaultBundle.defaultAddressIndex = addressIndex
//            defaultBundle.setDefault()
//        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
