//
//  SendView.swift
//  Wallet
//
//  Created by Ronald Mannak on 1/12/22.
//

import SwiftUI
import SafariWalletCore
//import UniformTypeIdentifiers

struct SendView: View {
    
    @EnvironmentObject var userSettings: UserSettings
    @ObservedObject var viewModel = ViewModel()
    @State var showConfirmPopup = false
    @State var to: String = ""
    @State var amount: String = ""
    @State var assetIndex: Int = 0
    
    var body: some View {
        Form {
         
            // MARK: - From
            Section(header: Text("From (click to copy to clipboard)")) {
                Text(userSettings.address?.addressString ?? "Error: select address in Settings")
                    .onTapGesture {
                        guard let address = userSettings.address?.addressString else { return }
                        #if os(iOS)
        //                UIPasteboard.general.setValue(address, forPasteboardType:  UTTypePlainText)
                        UIPasteboard.general.string = address
                        #elseif os(OSX)
                        let pasteBoard = NSPasteboard.general()
                        pasteBoard.clearContents()
                        pasteBoard.writeObjects([address as NSString])
                        #endif
                    }
                
                Picker(selection: $assetIndex, label: Text("Asset")) {
                    // TODO: alchemy call for erc 20 tokens?
                    ForEach(0 ..< 1) { _ in
                        Text(userSettings.network.symbol)
                    }
                }
                
                Text("Balance: \(viewModel.balance) \(userSettings.network.symbol.uppercased())")
                
            }
            
            // MARK: - Asset
            
            
            // MARK: - To
            Section(header: Text("TO")) {
                TextField("Address or ENS name", text: $to)
                
                HStack {
                    Text("Amount")
                    TextField("0", text: $amount)
                    Text(userSettings.network.symbol.uppercased())
                }
            }

            Button("Pay") {
                showConfirmPopup = true
                print("dc: \(Decimal(string: amount))")
            }
            .disabled(amount.count == 0 || Decimal(string: amount) == nil)
            .sheet(isPresented: $showConfirmPopup) {
                SendConfirmView(amount: "\(amount) \(userSettings.network.symbol.uppercased())")
                    .onDisappear {
                            //
                    }
                }
            .task {
                do {
                    assert(Thread.isMainThread)
                    try await viewModel.setup(userSettings: self.userSettings)
                    assert(Thread.isMainThread)
                    print("task")
                } catch {
                    print("🚨 \(error.localizedDescription)")
                }
            }
            .onAppear {
                print("on appear")
            }
        }
    }
    
    @MainActor
    class ViewModel: ObservableObject {
        
        @Published var balance: String = "" {
            didSet {
                print("balance was set: \(balance)")
                assert(Thread.isMainThread)
            }
        }
        
        private var client: AlchemyClient = AlchemyClient(network: .ethereum, key: ApiKeys.alchemyMainnet)! // TODO: Init can only fail if the URL is invalid, which shouldn't happen runtime. Refactor the client init.

//        @MainActor
        fileprivate func setup(userSettings: UserSettings) async throws {
            
            // TODO: move this to APIKeys?
            let key: String
            if case .ropsten = userSettings.network {
                key = ApiKeys.alchemyRopsten
                print("ropsten")
            } else {
                key = ApiKeys.alchemyMainnet
                print("main")
            }
            self.client = AlchemyClient(network: userSettings.network, key: key)!
            
            if let addressString = userSettings.address?.addressString, let ethBalance = try await client.ethGetBalance(address: addressString).etherValue {
                self.balance = ethBalance.description + "hello"
                print("Balance for \(addressString): \(ethBalance.description)")
                assert(Thread.isMainThread)
            } else {
                self.balance = "0 zero"
            }
        }
        
    }
}

struct SendView_Previews: PreviewProvider {
    static var previews: some View {
        SendView()
    }
}
