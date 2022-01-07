//
//  DeveloperView.swift
//  Wallet
//
//  Created by Ronald Mannak on 10/14/21.
//

import SwiftUI
import MEWwalletKit
import SafariWalletCore
#if DEBUG
struct DeveloperView: View {
    
    @EnvironmentObject var userSettings: UserSettings
    @State var walletCount: Int = 0
    @State var errorMessage: String = ""
    @State var presentOnboarding: Bool = false {
        didSet {
            self.countWallets()
        }
    }
    
    var body: some View {
        VStack {
            
            Text("Developer tools")
                .font(.title)
                .padding()
            
            if walletCount == 0 {
                Text("No wallets found")
            } else if walletCount == 1 {
                Text("1 wallet found")
            } else if walletCount < 1 {
                Text("Could not count wallets: \(errorMessage)")
            } else {
                Text("wallets found: \(walletCount)")
            }
            
            Spacer()
            
            Group {
                
                if let ensName = userSettings.address?.ensName {
                    Text(ensName)
                        .font(.title2)
                        .padding()
                }
                else if let address = userSettings.address?.addressString {
                    Text(address)
                        .font(.title2)
                        .padding()
                } else {
                    Text("no address set")
                }
                
                Text("Web3 test calls")
                    .font(.title3)
                    .padding()
                
                Button("get balance") {
                    Task {
                        do {
                            let client = EthereumClient(provider: .alchemy(key: ApiKeys.alchemyMainnet))!
                            let balance = try await client.ethGetBalance(address: "0xAb5801a7D398351b8bE11C439e05C5B3259aeC9B", blockNumber: .latest)
                            print(balance.description)
                            let height = try await client.ethBlockNumber()
                            print(height)
                        } catch {
                            print(error)
                        }
                    }
                }
                .buttonStyle(.bordered)
               
                Button("Call alchemy_getAssetTransfers") {
                  Task {
                     do {
                        let client = AlchemyClient(key: ApiKeys.alchemyMainnet)!
                        //https://docs.alchemy.com/alchemy/documentation/enhanced-apis/transfers-api
                        let transfers = try await client.alchemyAssetTransfers(fromBlock: Block(rawValue: "A97AB8"),
                                                                               toBlock: Block(rawValue: "A97CAC"),
                                                                               fromAddress: MEWwalletKit.Address(address: "3f5CE5FBFe3E9af3971dD833D26bA9b5C936f0bE"),
                                                                               contractAddresses: [
                                                                                MEWwalletKit.Address(address: "7fc66500c84a76ad7e9c93437bfc5ac33e2ddae9")!
                                                                               ],
                                                                               excludeZeroValue: true,
                                                                               maxCount: 5)
                        print(transfers)
                     } catch {
                        print(error)
                     }
                   }
                }
                .buttonStyle(.bordered)
            }
            
            Text("Wallet")
                .font(.title3)
                .padding()
            
            Button("Create a new test wallet") {
                Task {
                    do {
                        try await self.createTestWallet()
                    } catch {
                        print("Error creating test wallet: \(error.localizedDescription)")
                    }
                }
            }
            .padding(.top)
            
            Text("Instantly creates a new wallet with the default password 'password123' and makes it the default wallet. Takes up to 5 seconds in debug mode.")
                
//            Button("Delete all wallets on disk", role: .destructive) {
//                Task {
//                    try? await manager.deleteAllWalletsAndBundles()
//                }
//                
//            }
//            .buttonStyle(.borderedProminent)
//            .padding()
            
        }
        .padding()
        .onAppear {
            countWallets()
        }
        .sheet(isPresented: $presentOnboarding) { OnboardingView(isCancelable: true) }
        .environmentObject(userSettings)
    }
}

extension DeveloperView {
    
    func countWallets() {
        do {
            walletCount = try SharedDocument.listAddressBundles(network: .ethereum).count
        } catch {
            walletCount = -1
            errorMessage = error.localizedDescription
        }
    }

    func createTestWallet() async throws {
        // 1. Create HDWallet
        let root = try BIP39(bitsOfEntropy: 128)
        guard let seed = try root.seed() else { throw WalletError.addressGenerationError }
        let wallet: Wallet<PrivateKeyEth1> = try Wallet(seed: seed, network: .ethereum)
        
        // 2. Generate mainnet, Ropsten addresses
        let addresses = try wallet.generateAddresses(count: 5)
        let ropstenAddresses = try wallet.generateAddresses(count: 5, network: .ropsten)
        
        // 2. Save address bundles
        let id = UUID()
        let bundle = AddressBundle(id: id, walletName: "Eth \(id.uuidString)", type: .keystorePassword, network: .ethereum, addresses: addresses)
        try await bundle.save()
        let ropstenBundle = AddressBundle(id: id, walletName: "Ropsten \(id.uuidString)", type: .keystorePassword, network: .ropsten, addresses: ropstenAddresses)
        try await ropstenBundle.save()
        
        // 3. Save seed
        let keystore = try await KeystoreV3(bip39: root, password: "password123")
        try await keystore.save(name: id.uuidString)
        
        // 4. Store password in keychain
        try await KeychainPasswordItem.store(password: "password123", account: id.uuidString)
        
        countWallets()
    }
    
}

struct DeveloperView_Previews: PreviewProvider {
    static var previews: some View {
        DeveloperView()
    }
}

#endif
