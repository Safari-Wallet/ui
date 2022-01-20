//
//  SendView.swift
//  Wallet
//
//  Created by Ronald Mannak on 1/12/22.
//

import Combine
import MEWwalletKit
import SwiftUI
import SafariWalletCore
//import UniformTypeIdentifiers

struct SendView: View {
    
    @EnvironmentObject var userSettings: UserSettings
    @StateObject var viewModel = ViewModel()  // Will be kept and reused
//    @ObservedObject var viewModel: ViewModel    // Will be recreated
    @State var showConfirmPopup = false
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
                HStack(spacing: 5) {
                    TextField("Address or ENS name", text: $viewModel.toAddress)
                    toAddressIndicator
                }
                
                HStack {
                    Text("Amount")
                    TextField("0", text: $amount)
                    Text(userSettings.network.symbol.uppercased())
                }
            }

            Button("Pay") {
                showConfirmPopup = true
            }
            .disabled(amount.count == 0 || Decimal(string: amount) == nil)
            .sheet(isPresented: $showConfirmPopup) {
                SendConfirmView(amount: "\(amount) \(userSettings.network.symbol.uppercased())")
                    .onDisappear {
                            // do something
                    }
                }
            .task {
                await viewModel.setup(userSettings: self.userSettings)
            }
            .onChange(of: userSettings.address?.addressString) { _ in
                Task {
                    await viewModel.setup(userSettings: userSettings)
                }
            }
            .alert(viewModel.error?.localizedDescription ?? "Unknown error occurred", isPresented: $viewModel.showError) { }
        }
    }
    
    @ViewBuilder
    var toAddressIndicator: some View {
        switch viewModel.toAddressState {
        case .loading:
            ProgressView()
        case .valid:
            Image(systemName: "checkmark.circle.fill")
                .renderingMode(.template)
                .foregroundColor(.green)
        case .invalid:
            Image(systemName: "xmark.circle.fill")
                .renderingMode(.template)
                .foregroundColor(.red)
        default:
            EmptyView()
        }
    }
    
    @MainActor
    class ViewModel: ObservableObject {
        
        enum ToAddressState {
            case loading
            case valid
            case invalid
            case initial
        }
        
        @Published var balance: String = ""
        
        @Published var toAddress: String = ""
        var toHexAddress: String?
        
        @Published var toAddressState: ToAddressState = .initial
        
        @Published var showError: Bool = false
        var error: Error?
        
        private var cancellables = Set<AnyCancellable>()
        
        private var client: AlchemyClient = AlchemyClient(network: .ethereum, key: ApiKeys.alchemyMainnet)! // TODO: Init can only fail if the URL is invalid, which shouldn't happen runtime. Refactor the client init.
        private let ensResolver: ENSResolvable = ENSResolver(network: .ethereum, provider: .alchemy(key: ApiKeys.alchemyMainnet))
        
        init() {
            listenToAddressChange()
        }
        
        fileprivate func setup(userSettings: UserSettings) async {
            
            // TODO: move this to APIKeys?
            let key: String
            if case .ropsten = userSettings.network {
                key = ApiKeys.alchemyRopsten
            } else {
                key = ApiKeys.alchemyMainnet
            }
            self.client = AlchemyClient(network: userSettings.network, key: key)!
 
            do {
                if let addressString = userSettings.address?.addressString, let ethBalance = try await client.ethGetBalance(address: addressString).etherValue {
                    self.balance = ethBalance.description
                } else {
                    self.balance = "(ERROR)"
                }
            } catch URLError.cancelled {
                // ignore this error
            } catch {
                print(error)
                self.error = error
                self.showError = true
            }
        }
        
        func listenToAddressChange() {
            $toAddress
                .dropFirst()
                .debounce(for: .seconds(0.65), scheduler: RunLoop.main)
                .sink { [weak self] toAddress in
                    guard let self = self else { return }
                    self.handle(toAddress: toAddress)
                }
                .store(in: &cancellables)
        }
        
        private func handle(toAddress: String) {
            
            if toAddress.contains(".") { // improve ens validation
                Task {
                    do {
                        self.toAddressState = .loading
                        let address = try await self.ensResolver.resolve(ens: toAddress.lowercased())
                        self.toHexAddress = address
                        self.toAddressState = .valid
                    } catch {
                        self.error = ENSError.ensUnknown
                        self.showError = true
                        self.toAddressState = .invalid
                    }
                }
            } else if let address = Address(ethereumAddress: toAddress) {
                self.toHexAddress = address.address
                self.toAddressState = .valid
            } else if toAddress.isEmpty {
                self.toAddressState = .initial
            } else {
                self.toAddressState = .invalid
            }
        }
    }
}

struct SendView_Previews: PreviewProvider {
    static var previews: some View {
        SendView()
    }
}
