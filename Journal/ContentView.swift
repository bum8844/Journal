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
            .tint(MyLogTheme.accent)
            .fontDesign(.rounded)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: JournalDatabase.self, inMemory: true)
}
