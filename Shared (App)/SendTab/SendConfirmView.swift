//
//  SendConfirmView.swift
//  Wallet
//
//  Created by Ronald Mannak on 1/14/22.
//

import SwiftUI

struct SendConfirmView: View {
    
    let amount: String
    
    var body: some View {
        
        Form {
            Text("Sending \(amount)")
        }
    }
}

struct SendConfirmView_Previews: PreviewProvider {
    static var previews: some View {
        SendConfirmView(amount: "1.0 ETH")
    }
}
