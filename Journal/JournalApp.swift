//
//  JournalApp.swift
//  Journal
//
//  Created by IOS EST on 11/16/26.
//

import SwiftUI
import SwiftData
import UserNotifications

@main
struct JournalApp: App {
    // 테마 선택은 UserDefaults에 저장돼 재실행 후에도 유지됩니다. 최초 실행에서는 시스템 테마를 따릅니다.
    @AppStorage("appTheme") private var appTheme: AppTheme = .system
    // 앱이 켜진 직후에 커버 화면을 잠깐 보여 주고 사라지게 합니다.
    @State private var showsCover = true

    init() {
        // 알림을 눌러 앱이 켜지는 경우도 받으려면 앱이 시작될 때 담당을 등록해 둬야 합니다.
        UNUserNotificationCenter.current().delegate = NotificationCoordinator.shared
    }

    var body: some Scene {
        WindowGroup {
            // 테마 상태를 설정 탭과 공유하고, WindowGroup의 루트에서 지정해 세 탭 모두에 적용합니다.
            ContentView(theme: $appTheme)
                .preferredColorScheme(appTheme.colorScheme)
                .modifier(AppTextSizeModifier())
#if os(iOS)
                .modifier(AppBrightnessModifier())
#endif
                // 위의 테마(라이트/다크) 설정이 커버에도 그대로 적용되도록 모든 수정자 뒤에 겹칩니다.
                .overlay {
                    if showsCover {
                        LaunchCoverView()
                            .transition(.opacity)
                    }
                }
                .task {
                    try? await Task.sleep(for: .seconds(1))
                    withAnimation(.easeOut(duration: 0.35)) { showsCover = false }
                }
        }
        // 팀 공통 회고 모델의 저장소를 화면 계층에 제공해 하위 화면에서 @Query를 사용할 수 있게 합니다.
        .modelContainer(for: JournalDatabase.self)
    }
}
