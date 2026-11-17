import Foundation

/// 기간 종료 알림을 보내는 시각 방식. 설정에서 고르며 앱 전체에 적용됩니다.
/// 원시 문자열이 @AppStorage에 저장되므로 값을 바꾸지 않습니다.
enum PeriodEndReminderMode: String, CaseIterable {
    /// 종료일 낮 12시에 한 번 (기본값)
    case noon
    /// 종료일 09:00부터 21:00까지 3시간 간격
    case everyThreeHours

    static let storageKey = "periodEndReminderMode"

    /// 저장된 설정. 값이 없거나 알 수 없으면 기본값(낮 12시)입니다.
    static var current: PeriodEndReminderMode {
        UserDefaults.standard.string(forKey: storageKey).flatMap(Self.init(rawValue:)) ?? .noon
    }

    var title: String {
        switch self {
        case .noon: "낮 12시 한 번 (기본)"
        case .everyThreeHours: "3시간 간격"
        }
    }

    /// 종료일에 알림을 보내는 시각(시)
    var hours: [Int] {
        switch self {
        case .noon: [12]
        case .everyThreeHours: [9, 12, 15, 18, 21]
        }
    }

    /// 작성 화면과 설정 화면에서 보여 주는 안내 문구
    var guide: String {
        switch self {
        case .noon: "종료일 낮 12시에 알림을 보내요."
        case .everyThreeHours: "종료일 09:00 · 12:00 · 15:00 · 18:00 · 21:00에 알림을 보내요."
        }
    }
}
