//
//  ContentView.swift
//  Journal
//
//  Created by IOS EST on 11/16/26.
//

import SwiftUI
import SwiftData

/// 회고·통계·설정 화면을 하단 탭에 연결하고 각 화면에 필요한 값을 전달합니다.
struct ContentView: View {
    // JournalApp에 저장된 테마를 읽고, 설정 화면에서 바꾼 값을 같은 상태에 반영합니다.
    @Binding var theme: AppTheme
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        TabView {
            // JournalListView 안에 NavigationStack이 있어 탭에서 다시 감싸지 않습니다.
            JournalListView()
#if DEBUG
                .task { JournalDatabase.seedSamplesIfNeeded(in: modelContext) }
#endif
                .tabItem { Label("회고", systemImage: "list.bullet.rectangle") }

            NavigationStack {
                ReflectionStatisticsView()
            }
            .tabItem { Label("통계", systemImage: "chart.bar") }

            NavigationStack {
                // 설정의 Picker가 바꾼 값은 이 바인딩을 통해 JournalApp까지 전달됩니다.
                ThemeSettingsView(theme: $theme)
            }
            .tabItem { Label("설정", systemImage: "gearshape") }
        }
    }
}

// 프리뷰는 메모리에만 저장하는 별도 컨테이너를 사용합니다. 실제 앱의 회고 데이터에는 접근하지 않습니다.
#Preview {
    ContentView(theme: .constant(.system))
        .modelContainer(for: JournalDatabase.self, inMemory: true)
}
