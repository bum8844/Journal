//
//  JournalApp.swift
//  Journal
//
//  Created by IOS EST on 11/16/26.
//

import SwiftUI
import SwiftData

@main
struct JournalApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: JournalDatabase.self)
    }
}
