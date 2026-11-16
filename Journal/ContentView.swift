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
            // 시안 G는 밝은 배경 전용이라 다크 모드에서도 라이트로 고정합니다.
            .preferredColorScheme(.light)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: MyLog.self, inMemory: true)
}
