//
//  GeometryOverlay.swift
//  Wallet (iOS)
//
//  Created by Stefano on 22.12.21.
//

import SwiftUI

extension View {
    
    func onGeometryChange<Value>(
        compute: @escaping (GeometryProxy) -> Value,
        onChange: @escaping (Value) -> Void
    ) -> some View where Value: Equatable {
        let key = TaggedKey<Value, ()>.self
        return self.overlay(GeometryReader { proxy in
            Color.clear.preference(key: key, value: compute(proxy))
        }).onPreferenceChange(key) { value in
            DispatchQueue.main.async {
                onChange(value.unsafelyUnwrapped)
            }
        }.preference(key: key, value: nil)
    }
}

struct TaggedKey<Value, Tag>: PreferenceKey {
    static var defaultValue: Value? { nil }
    static func reduce(value: inout Value?, nextValue: () -> Value?) {
        value = value ?? nextValue()
    }
}
