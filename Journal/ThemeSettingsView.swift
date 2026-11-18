import SwiftUI
import SwiftData

/// 시스템 설정을 따르거나 앱의 화면 색상 모드를 지정합니다.
/// 원시 문자열은 @AppStorage에 저장되며 화면에 표시하는 한글 이름과 독립적입니다.
enum AppTheme: String, CaseIterable {
    case system
    case light
    case dark

    var title: String {
        switch self {
        case .system: "시스템"
        case .light: "라이트"
        case .dark: "다크"
        }
    }

    /// 시스템의 경우 nil을 반환해 앱이 기기의 색상 모드를 따르게 합니다.
    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}

/// 하단 설정 탭에서 화면 테마, 글자 크기와 화면 밝기를 바꿉니다.
struct ThemeSettingsView: View {
    @Binding var theme: AppTheme
    @Environment(\.modelContext) private var modelContext
    @AppStorage(PeriodEndReminderMode.storageKey) private var reminderMode: PeriodEndReminderMode = .noon
    @AppStorage(DisplaySettings.textSizeKey) private var textSize: AppTextSize = .system
#if os(iOS)
    @AppStorage(DisplaySettings.usesCustomBrightnessKey) private var usesCustomBrightness = false
    @AppStorage(DisplaySettings.brightnessKey) private var brightness = DisplaySettings.initialBrightness
#endif

    var body: some View {
        Form {
            Section("화면 테마") {
                // 각 항목의 AppTheme 값이 바인딩을 통해 JournalApp의 저장값을 바꿉니다.
                Picker("테마", selection: $theme) {
                    ForEach(AppTheme.allCases, id: \.self) { option in
                        Text(option.title).tag(option)
                    }
                }
            }
            .listRowBackground(JournalTheme.glassFill)

            Section("글자 크기") {
                Picker("글자 크기", selection: $textSize) {
                    ForEach(AppTextSize.allCases, id: \.self) { option in
                        Text(option.title).tag(option)
                    }
                }
            }
            .listRowBackground(JournalTheme.glassFill)

            Section {
                Picker("종료일 알림 시각", selection: $reminderMode) {
                    ForEach(PeriodEndReminderMode.allCases, id: \.self) { option in
                        Text(option.title).tag(option)
                    }
                }
                .pickerStyle(.inline)
                .labelsHidden()
            } header: {
                Text("기간 종료 알림")
            } footer: {
                Text("\(reminderMode.guide) 중요도 1단계인 기간 회고에만 보내요.")
            }
            .listRowBackground(JournalTheme.glassFill)
            // 바꾸면 이미 예약된 알림에도 새 방식을 적용한다
            .onChange(of: reminderMode) { resyncReminders() }

#if os(iOS)
            Section("화면 밝기") {
                Picker("밝기 방식", selection: $usesCustomBrightness) {
                    Text("기기 밝기 사용").tag(false)
                    Text("직접 조절").tag(true)
                }

                if usesCustomBrightness {
                    LabeledContent("밝기") {
                        Text(brightness, format: .percent.precision(.fractionLength(0)))
                    }
                    Slider(value: $brightness, in: 0...1, step: 0.05) {
                        Text("화면 밝기")
                    }
                    .accessibilityValue(brightness.formatted(.percent.precision(.fractionLength(0))))
                }
            }
            .listRowBackground(JournalTheme.glassFill)
#endif
        }
        // 팀 공통 테마: 시스템 폼 배경을 숨기고 그라데이션 배경과 유리 카드 행을 사용합니다.
        .scrollContentBackground(.hidden)
        .journalBackground()
        .foregroundStyle(JournalTheme.text)
        .tint(JournalTheme.accent)
        .navigationTitle("설정")
    }

    /// 저장된 모든 회고의 알림을 새 방식으로 다시 예약합니다.
    /// 회고 id만 넘기고, 각 회고의 상태는 처리하는 순간 저장소에서 다시 읽습니다.
    /// 그래서 처리 도중 삭제하거나 중요도를 낮춘 회고가 옛 값으로 되살아나지 않습니다.
    private func resyncReminders() {
        let journals = (try? modelContext.fetch(FetchDescriptor<JournalDatabase>())) ?? []
        let ids = journals.map(\.id)
        Task { await PeriodReminderScheduler.shared.resyncAll(journalIDs: ids, in: modelContext) }
    }
}
