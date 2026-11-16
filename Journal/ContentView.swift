//
//  ContentView.swift
//  Journal
//
//  Created by IOS EST on 11/16/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        JournalListView()
            #if DEBUG
            .task { JournalDatabase.seedSamplesIfNeeded(in: modelContext) }
            #endif
    }
}

#Preview {
    ContentView()
        .modelContainer(for: JournalDatabase.self, inMemory: true)
}
