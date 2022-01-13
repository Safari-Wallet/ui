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
    
    var body: some View {
        Form {
         
            // MARK: - From
            Section(header: Text("From")) {
                Text(userSettings.address?.addressString ?? "Error: select address in Settings")
            }
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
            
            // MARK: - To
            Section(header: Text("TO")) {
                TextField("To address or ENS name", text: $to)                
            }
         
        }
    }
}

struct SendView_Previews: PreviewProvider {
    static var previews: some View {
        SendView()
    }
}
