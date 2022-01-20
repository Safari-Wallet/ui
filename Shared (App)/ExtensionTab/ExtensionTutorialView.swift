//
//  ExtensionTutorialView.swift
//  Wallet
//
//  Created by Ronald Mannak on 1/6/22.
//

import SwiftUI

extension Color {
    public static var extensionBlue: Color { Color(hex: 0x007AFF) }
}

struct ExtensionTutorialView: View {
    
    @Environment(\.openURL) var openURL
    
    var body: some View {
        
        VStack(spacing: 12) {
            
            Text("To connect extension in Safari:")
                .font(.title2)
                .bold()
                .padding(.bottom, 48)
            
            Image("ConnectExtension1")

            Image(systemName: "arrow.down")
                .font(Font.system(.title2).bold())
                .foregroundColor(.extensionBlue)
            
            Image("ConnectExtension2")

            Image(systemName: "arrow.down")
                .font(Font.system(.title2).bold())
                .foregroundColor(.extensionBlue)
            
            Image("ConnectExtension3")

            HStack {
                Button {
                    openURL(URL(string: "https://youtu.be/z13qnzUQwuI")!)
                } label: {
                    HStack {
                        Spacer()
                        Label("Launch Safari", systemImage: "safari")
                        Spacer()
                    }
                    .padding(.vertical, 5)
                }
                .foregroundColor(.white)
                .background(Color.extensionBlue.cornerRadius(8))
                .buttonStyle(.bordered)
                .padding(.horizontal, 20)
            }

        }
        
    }
}

struct ExtensionTutorialView_Previews: PreviewProvider {
    static var previews: some View {
        ExtensionTutorialView()
    }
}
