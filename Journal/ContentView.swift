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
    @State private var selectedTab: AppTab = .journal
    private let router = NotificationRouter.shared

    private enum AppTab: Hashable {
        case journal, statistics, settings
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            // JournalListView 안에 NavigationStack이 있어 탭에서 다시 감싸지 않습니다.
            JournalListView()
                .tabItem { Label("회고", systemImage: "list.bullet.rectangle") }
                .tag(AppTab.journal)

            NavigationStack {
                ReflectionStatisticsView()
            }
            .tabItem { Label("통계", systemImage: "chart.bar") }
            .tag(AppTab.statistics)

            NavigationStack {
                // 설정의 Picker가 바꾼 값은 이 바인딩을 통해 JournalApp까지 전달됩니다.
                ThemeSettingsView(theme: $theme)
            }
            .tabItem { Label("설정", systemImage: "gearshape") }
            .tag(AppTab.settings)
        }
        // 알림을 누르면 어느 탭에 있었든 회고 탭으로 이동한다. 상세 화면은 목록이 연다.
        .onChange(of: router.pendingJournalID, initial: true) { _, id in
            if id != nil { selectedTab = .journal }
        }
    }
}

// 프리뷰는 메모리에만 저장하는 별도 컨테이너를 사용합니다. 실제 앱의 회고 데이터에는 접근하지 않습니다.
#Preview {
    ContentView(theme: .constant(.system))
        .modelContainer(for: JournalDatabase.self, inMemory: true)
}
