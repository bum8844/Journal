// [임시 확인용] 작성 화면에서 기간이(가) 저장·표시되는지 확인하려고 만든 간단한 폼입니다.
// 기간·사진 입력 담당이 만든 폼이 나오면 이 파일을 지우고 JournalEditorView의 연결 한 줄만 바꿉니다.

import SwiftUI

/// 기록 기간을 고르는 화면. 하루 회고와 기간 회고 중 하나를 고르고, 기간이면 시작일·종료일을 입력합니다.
/// 값은 바인딩으로 작성 화면에 바로 전달됩니다.
struct PeriodSheet: View {
    @Binding var isPeriod: Bool
    @Binding var startDate: Date
    @Binding var endDate: Date
    @Environment(\.dismiss) private var dismiss

    /// 종료일이 시작일보다 빠르지 않은지 확인합니다. (시각은 무시하고 날짜만 비교)
    static func isValid(isPeriod: Bool, startDate: Date, endDate: Date) -> Bool {
        !isPeriod || Calendar.current.startOfDay(for: endDate) >= Calendar.current.startOfDay(for: startDate)
    }

    private var isValid: Bool {
        Self.isValid(isPeriod: isPeriod, startDate: startDate, endDate: endDate)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("기록 기간", selection: $isPeriod) {
                        Text("하루").tag(false)
                        Text("기간").tag(true)
                    }
                    .pickerStyle(.segmented)
                }
                .listRowBackground(JournalTheme.glassFill)

                if isPeriod {
                    Section {
                        DatePicker("시작일", selection: $startDate, displayedComponents: .date)
                        DatePicker("종료일", selection: $endDate, displayedComponents: .date)
                    } footer: {
                        if !isValid {
                            Text("종료일은 시작일보다 빠를 수 없어요. 날짜를 다시 선택해 주세요.")
                                .foregroundStyle(.red)
                        }
                    }
                    .listRowBackground(JournalTheme.glassFill)
                }
            }
            .scrollContentBackground(.hidden)
            .journalBackground()
            .foregroundStyle(JournalTheme.text)
            .navigationTitle("기록 기간")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    // 날짜가 잘못된 동안은 닫을 수 없어 잘못된 값이 그대로 남지 않습니다.
                    Button("완료") { dismiss() }
                        .disabled(!isValid)
                }
            }
        }
        .tint(JournalTheme.accent)
        // 기기 언어와 상관없이 날짜 선택 화면(월·요일·연도)을 한글로 보여 줍니다.
        .environment(\.locale, Locale(identifier: "ko_KR"))
        .interactiveDismissDisabled(!isValid)
        .presentationDetents([.medium])
    }
}

#Preview {
    @Previewable @State var isPeriod = true
    @Previewable @State var start = Date()
    @Previewable @State var end = Date()

    PeriodSheet(isPeriod: $isPeriod, startDate: $start, endDate: $end)
}
