//
//  ContentView.swift
//  Journal
//
//  Created by IOS EST on 11/16/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        MyLogListView()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: MyLog.self, inMemory: true)
}
