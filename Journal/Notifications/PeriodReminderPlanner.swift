import Foundation

/// 예약할 알림 한 건. 화면과 알림 센터를 몰라서 규칙만 따로 검증할 수 있습니다.
struct PeriodReminder: Equatable {
    let identifier: String
    let fireDate: Date
    let title: String
    let body: String
    let journalID: UUID
}

/// 알림 계산에 필요한 회고 값. 모델(SwiftData)을 직접 넘기지 않고 값만 복사해 씁니다.
struct ReminderSubject: Equatable {
    let id: UUID
    let title: String
    let isPeriod: Bool
    let importance: ReflectionImportance
    let endDate: Date?

    init(id: UUID, title: String, isPeriod: Bool, importance: ReflectionImportance, endDate: Date?) {
        self.id = id
        self.title = title
        self.isPeriod = isPeriod
        self.importance = importance
        self.endDate = endDate
    }

    init(_ journal: JournalDatabase) {
        self.init(
            id: journal.id,
            title: journal.title,
            isPeriod: journal.isPeriod,
            importance: journal.importance,
            endDate: journal.endDate
        )
    }

    /// 종료 알림 대상: 기간 회고이면서 중요도 1단계
    var isReminderTarget: Bool { isPeriod && importance == .high && endDate != nil }
}

/// 어떤 회고에 어느 시각의 알림을 예약할지 정하는 규칙
enum PeriodReminderPlanner {
    /// 한 회고의 알림 식별자는 모두 이 접두어로 시작합니다. 취소할 때 접두어로 찾습니다.
    static func identifierPrefix(for journalID: UUID) -> String {
        "period-end.\(journalID.uuidString)."
    }

    /// 종료일 중 아직 지나지 않은 시각만 돌려줍니다. 대상이 아니면 빈 배열입니다.
    /// - 같은 회고, 같은 날, 같은 시각은 식별자가 같아 중복 예약되지 않습니다.
    static func reminders(
        for subject: ReminderSubject,
        mode: PeriodEndReminderMode,
        now: Date = .now,
        calendar: Calendar = .current
    ) -> [PeriodReminder] {
        guard subject.isReminderTarget, let endDate = subject.endDate else { return [] }

        let day = calendar.startOfDay(for: endDate)
        let dayParts = calendar.dateComponents([.year, .month, .day], from: day)
        let dayText = String(format: "%04d%02d%02d", dayParts.year ?? 0, dayParts.month ?? 0, dayParts.day ?? 0)
        let title = subject.title.trimmingCharacters(in: .whitespacesAndNewlines)

        return mode.hours.compactMap { hour in
            guard let fireDate = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: day),
                  fireDate > now else { return nil }
            return PeriodReminder(
                identifier: identifierPrefix(for: subject.id) + dayText + String(format: "-%02d", hour),
                fireDate: fireDate,
                title: "기간 회고가 오늘 끝나요",
                body: "‘\(title)’ 회고 기간이 오늘 끝나요. 마무리 기록을 남겨 보세요.",
                journalID: subject.id
            )
        }
    }
}
