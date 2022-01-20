//
//  Intro1View.swift
//  Wallet
//
//  Created by Ronald Mannak on 10/14/21.
//

import SwiftUI

struct Intro1View: View {
    
    @Binding var state: OnboardingState
    @Binding var tabIndex: Int
    
    var body: some View {
        
        VStack {
            
            ExtensionTutorialView()
            
            HStack {
                Button {
                    state = .dismiss
                } label: {
                    HStack {
                        Spacer()
                        Text("I will do this later")
                        Spacer()
                    }
                    .padding(.vertical, 5)
                }
                .foregroundColor(.white)
                .tint(.extensionBlue)
                .buttonStyle(.bordered)
                .padding(.horizontal, 20)
            }
        }
        .padding()        
    }
}

struct Intro1View_Previews: PreviewProvider {
    @State static var state: OnboardingState = .appIntro
    @State static var tabIndex: Int = 0
    static var previews: some View {
        Intro1View(state:$state, tabIndex: $tabIndex)
    }
}
