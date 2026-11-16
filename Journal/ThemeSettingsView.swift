import SwiftUI

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

/// 테마 선택 화면입니다. 선택한 값의 저장과 앱 전체 적용은 JournalApp에서 처리합니다.
struct ThemeSettingsView: View {
    @Binding var theme: AppTheme

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
        }
        .navigationTitle("설정")
    }
}
