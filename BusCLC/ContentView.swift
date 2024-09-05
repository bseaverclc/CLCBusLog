//
//  ContentView.swift
//  BusCLC
//
//  Created by BRENNAN REINHARD on 8/20/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Button("Test commit") {
                Task {
                    await testCommitToDB()
                }
            }
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
