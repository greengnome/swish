//
//  ContentView.swift
//  Swish
//
//  Created by Kirill Gladkov on 14/08/2026.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                Image(systemName: "timer")
                    .font(.system(size: 40))
                    .foregroundStyle(.tint)

                Text("Swish")
                    .font(.largeTitle.bold())

                Text("Foundation ready")
                    .foregroundStyle(.secondary)
            }
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("foundation.root")
            .navigationTitle("Swish")
        }
    }
}

#Preview {
    ContentView()
}
