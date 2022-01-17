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
    
    @ObservedObject var viewModel = AccountSelectionViewModel()
    @State var presentNewWalletMenu = false
    @State var presentOnboarding: Bool = false
    @EnvironmentObject var userSettings: UserSettings
            
    var body: some View {
    
        Form {
            if viewModel.bundles.count > 0 {
                // MARK: - Wallet selection
                Section(header: Text("Wallet")) {
                    Picker("HD Wallets", selection: $viewModel.bundleIndex) {
                        ForEach(0 ..< viewModel.bundles.count, id:\.self) { i in
                            let bundle = viewModel.bundles[i]
                            Text(bundle.walletName)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.inline)
                    .onChange(of: viewModel.bundleIndex) { bundleIndex in
                        viewModel.showBundle(index: bundleIndex)
                    }
                }

                // MARK: - Accounts selection
                Section(header: Text("Accounts in wallet")) {
                    if let bundle = viewModel.selectedBundle() {
                        Picker("Accounts", selection: $viewModel.addressIndex) {
                            ForEach(bundle.addresses, id: \.id) { address in
                                Text(address.ensName ?? address.addressString)
                            }
                        }
                        .labelsHidden()
                        .pickerStyle(.inline)
                    }
                }
            }
                       
            // MARK: - Network selection
            if userSettings.devMode == true {
                Section(header: Text("Network")) {
                    Picker(selection: $viewModel.networkIndex, label: Text("")) {
                        ForEach(viewModel.networks.indices) { i in
                            Text(viewModel.networks[i].name).tag(i)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.inline)
                    .onChange(of: viewModel.networkIndex) { networkIndex in
                        Task {
                            try? await viewModel.change(networkIndex: networkIndex, defaultBundle: userSettings.bundle)
                        }
                    }
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
        .task {
            try? await viewModel.setup(network: userSettings.network, defaultBundle: userSettings.bundle)
        }
        .onDisappear {
            guard let bundle = viewModel.selectedBundle() else { return }
            bundle.defaultAddressIndex = viewModel.addressIndex
            userSettings.bundle = bundle
        }
        .sheet(isPresented: $presentOnboarding) {
            OnboardingView(isCancelable: true)
                .onDisappear {
                    Task {
                        try? await viewModel.setup(network: userSettings.network, defaultBundle: userSettings.bundle)
                    }
                }
        }
        .environmentObject(userSettings)
    }
}

extension SettingsView {
    
    @MainActor
    class AccountSelectionViewModel: ObservableObject {
        
        @Published var bundleIndex: Int = 0
        
        @Published var addressIndex: Int = 0 {
            didSet {
                selectedBundle()?.defaultAddressIndex = addressIndex
            }
        }
        
        @Published var networkIndex: Int = 0
        
        @Published var bundles = [AddressBundle]()
        
        @Published var addresses = [AddressItem]()
        
        let networks: [Network] = [.ethereum, .ropsten]
        
        func selectedBundle() -> AddressBundle? {
            guard bundleIndex < bundles.count else { return nil }
            return bundles[bundleIndex]
        }
                
        func setup(network: Network, defaultBundle: AddressBundle? = nil) async throws {
            if case .ethereum = network  {
                networkIndex = 0
            } else {
                networkIndex = 1
            }
            
            self.bundles = try await AddressBundle.loadAddressBundles(network: network).sorted(by: { $0.walletName < $1.walletName
            })
            
            // Find the default bundle if provided
            if let defaultBundle = defaultBundle, let bundleIndex = bundles.firstIndex(of: defaultBundle) {
                self.bundleIndex = bundleIndex
                self.addresses = defaultBundle.addresses
                self.addressIndex = defaultBundle.defaultAddressIndex
            } else {
                self.bundleIndex = 0
                self.addresses = bundles.first?.addresses ?? []
                self.addressIndex = 0
            }
        }
        
        func showBundle(index: Int) {
            guard bundleIndex < self.bundles.count else { return }
            let bundle = self.bundles[bundleIndex]
            self.addresses = bundle.addresses
            self.addressIndex = bundle.defaultAddressIndex
        }
        
        func change(networkIndex: Int, defaultBundle: AddressBundle?) async throws {
            
            if networkIndex == 0 {
                try await setup(network: .ethereum, defaultBundle: defaultBundle)
            } else if networkIndex == 1 {
                try await setup(network: .ropsten, defaultBundle: defaultBundle)
            }
        }
        
        func reset() {
            self.bundles = [AddressBundle]()
            self.addresses = [AddressItem]()
            self.bundleIndex = 0
            self.addressIndex = 0
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
