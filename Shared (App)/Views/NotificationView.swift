//
//  NotificationView.swift
//  Wallet
//
//  Created by Stefano on 31.12.21.
//

import SwiftUI

struct NotificationViewModifier: ViewModifier {
    
    let text: String
    
    @Binding private var show: Bool
    @State private var dragOffset: CGFloat = .zero
    @State private var timer = Timer.publish(every: 2.5, on: .main, in: .common).autoconnect()
    
    init(
        show: Binding<Bool>,
        text: String
    ) {
        self._show = show
        self.text = text
    }
    
    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            content
            if show {
                NotificationView(text: text)
                    .padding([.leading, .trailing], 20)
                    .onReceive(timer) { input in
                        show = false
                    }
                    .transition(.move(edge: .top))
                    .offset(y: dragOffset)
                    .zIndex(1)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                guard value.translation.height > 0 else { return }
                                dragOffset = value.translation.height
                            }
                            .onEnded { value in
                                if dragOffset > 0 || value.predictedEndTranslation.height > 0 {
                                    show = false
                                }
                                dragOffset = 0
                            }
                    )
            }
        }
        .animation(.easeInOut(duration: 0.3), value: show)
        .animation(.linear, value: dragOffset)
    }
}

struct NotificationView: View {
    
    let text: String
    
    var body: some View {
        HStack {
            Text(text)
                .font(.body)
                .lineLimit(3)
        }
        .frame(maxWidth: .infinity)
        .padding([.leading, .trailing], 8)
        .padding([.top, .bottom], 12)
        .background(Color.red)
        .foregroundColor(.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

extension View {
    
    func notification(
        show: Binding<Bool>,
        text: String
    ) -> some View {
        modifier(
            NotificationViewModifier(
                show: show,
                text: text
            )
        )
    }
}

struct NotificationView_Previews: PreviewProvider {
    
    struct Preview: View {
        
        @State var show: Bool = false
        
        var body: some View {
            VStack {
                Text("Hello")
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.blue)
            .notification(show: $show, text: "Something went")
            .onTapGesture {
                show.toggle()
            }
        }
    }
    
    static var previews: some View {
        Preview()
    }
}
