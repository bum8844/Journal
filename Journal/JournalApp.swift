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
    // 테마 선택은 UserDefaults에 저장돼 재실행 후에도 유지됩니다. 최초 실행에서는 시스템 테마를 따릅니다.
    @AppStorage("appTheme") private var appTheme: AppTheme = .system

    var body: some Scene {
        WindowGroup {
            // 테마 상태를 설정 탭과 공유하고, WindowGroup의 루트에서 지정해 세 탭 모두에 적용합니다.
            ContentView(theme: $appTheme)
                .preferredColorScheme(appTheme.colorScheme)
                .modifier(AppTextSizeModifier())
#if os(iOS)
                .modifier(AppBrightnessModifier())
#endif
        }
        // 팀 공통 회고 모델의 저장소를 화면 계층에 제공해 하위 화면에서 @Query를 사용할 수 있게 합니다.
        .modelContainer(for: JournalDatabase.self)
    }
}
