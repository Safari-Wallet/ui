//
//  CreatePasswordView.swift
//  Wallet
//
//  Created by Ronald Mannak on 10/13/21.
//

import SwiftUI
import SafariWalletCore
import MEWwalletKit

struct CreatePasswordView: View {
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userSettings: UserSettings
    
    let bip39: BIP39
    
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var creatingWallet = false
    @Binding var walletWasSaved: Bool
    
    #if DEBUG
    let minimumPasswordLength = 3
    #else
    let minimumPasswordLength = 8
    #endif
    @State private var password = ""
    @State private var confirmPassword = ""
    
    var body: some View {
        
        VStack {
            Text("Set password")
                .font(.title)
            
            Spacer()
            
            Text("password must be at least \(minimumPasswordLength) characters long")
            
            SecureField("Enter a password", text: $password)
            
            SecureField("Confirm password", text: $confirmPassword)
            
            Spacer()
            
            HStack(spacing: 8) {
                
                Button("Cancel") {
                    // FIXME: disabled property is ignored 
                    if creatingWallet == false {
                        dismiss()
                    }
                }.disabled(creatingWallet == true)
                
                Spacer()
                
                Button("Save wallet") {
                    Task {
                        do {
                            creatingWallet = true
                            try await createWallet()
                            walletWasSaved = true
                            dismiss()
                            creatingWallet = false
                        } catch {
                            errorMessage = error.localizedDescription
                            showingError = true
                            creatingWallet = false
                        }
                    }
                }
                .disabled(password != confirmPassword || password.count < minimumPasswordLength || creatingWallet == true)
                .alert(isPresented: $showingError) {
                    Alert(
                        title: Text("Error: Unable to save wallet"),
                        message: Text(self.errorMessage)
                    )
                }
            }
            .padding(.bottom, 32)
        }
        .padding()     
    }
}

// MARK: - Wallet methods
extension CreatePasswordView {
    
    func createWallet() async throws {
        
        // 1. Create HDWallet
        guard let seed = try bip39.seed() else { throw WalletError.addressGenerationError }
        let wallet: Wallet<PrivateKeyEth1> = try Wallet(seed: seed, network: .ethereum)
        
        // 2. Generate mainnet and Ropsten addresses
        let addresses = try wallet.generateAddresses(count: 5)
        let ropstenAddresses = try wallet.generateAddresses(count: 5, network: .ropsten)
        
        // 3. Create default name for bundle
        let numberOfEthBundles = AddressBundle.numberOfBundles(network: .ethereum) ?? 0
        let ethBundleName = "Eth Wallet \(numberOfEthBundles+1)"
        
        let numberOfRopBundles = AddressBundle.numberOfBundles(network: .ropsten) ?? 0
        let ropstenbundleName = "Ropsten Wallet \(numberOfRopBundles+1)"
                
        // 3. Save address bundles
        let id = UUID()
        let bundle = AddressBundle(id: id, walletName: ethBundleName, type: .keystorePassword, network: .ethereum, addresses: addresses)
        try await bundle.save()
        let ropstenBundle = AddressBundle(id: id, walletName: ropstenbundleName, type: .keystorePassword, network: .ropsten, addresses: ropstenAddresses)
        try await ropstenBundle.save()
        
        // 4. Save seed
        let keystore = try await KeystoreV3(bip39: bip39, password: password)
        try await keystore.save(name: id.uuidString)
            
        // 5. Store password in keychain
        try await KeychainPasswordItem.store(password: password, account: id.uuidString)
                
        // 6. Set default wallet
        userSettings.bundle = bundle 
        
        // 7. Print debug
        #if DEBUG
        print(addresses)
        #endif

    }
}

struct CreatePasswordView_Previews: PreviewProvider {
    @State static var state: OnboardingState = .createWallet
    @State static var walletWasSaved = false
    static var previews: some View {
        CreatePasswordView(bip39: try! BIP39(mnemonic: "abandon amount liar amount expire adjust cage candy arch gather drum buyer"), walletWasSaved: $walletWasSaved)
    }
}

