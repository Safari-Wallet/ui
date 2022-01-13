//
//  SendView.swift
//  Wallet
//
//  Created by Ronald Mannak on 1/12/22.
//

import SwiftUI
//import UniformTypeIdentifiers

struct SendView: View {
    
    @EnvironmentObject var userSettings: UserSettings
    @State var to: String = ""
    @State var amount: String = ""
    @State var balance: String = ""
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
                    ForEach(0 ..< 1) { _ in
                        Text(userSettings.network.symbol)
                    }
                }
                
                Text("Balance: \(balance) \(userSettings.network.symbol.uppercased())")
                
            }
            
            // MARK: - Asset
            
            
            // MARK: - To
            Section(header: Text("TO")) {
                TextField("To address or ENS name", text: $to)
                
                HStack {
                    Text("Amount")
                    TextField("0", text: $amount)
                    Text(userSettings.network.symbol.uppercased())
                }
            }
         
        }
    }
}

struct SendView_Previews: PreviewProvider {
    static var previews: some View {
        SendView()
    }
}
