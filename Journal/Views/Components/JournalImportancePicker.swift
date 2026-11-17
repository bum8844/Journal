import SwiftUI

/// 회고 중요도(1 · 높음 / 2 · 보통 / 3 · 낮음) 선택 UI. 하루·기간 회고 모두에서 고를 수 있습니다.
/// 기간 회고에서 1단계를 고르면 종료일 알림 시각을 안내합니다. (설정에서 고른 방식을 따릅니다)
struct JournalImportancePicker: View {
    @Binding var importance: ReflectionImportance
    /// 기간 회고일 때만 알림 안내를 보여 줍니다.
    let isPeriod: Bool

    @AppStorage(PeriodEndReminderMode.storageKey) private var reminderMode: PeriodEndReminderMode = .noon

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("중요도")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(JournalTheme.subText)

            Picker("중요도", selection: $importance) {
                ForEach(ReflectionImportance.allCases, id: \.self) { option in
                    Text(option.title).tag(option)
                }
            }
            .pickerStyle(.segmented)

            if isPeriod && importance == .high {
                FormatGuideBanner(text: reminderMode.guide)
            }
        }
    }
}

#Preview("기간 + 1단계") {
    @Previewable @State var importance = ReflectionImportance.high

    JournalImportancePicker(importance: $importance, isPeriod: true)
        .padding(20)
        .journalBackground()
}

#Preview("하루 · 기본값") {
    @Previewable @State var importance = ReflectionImportance.normal

    JournalImportancePicker(importance: $importance, isPeriod: false)
        .padding(20)
        .journalBackground()
}
