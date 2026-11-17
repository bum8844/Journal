import Foundation
import UserNotifications

/// 알림 권한 상태
enum ReminderAuthorization: Equatable {
    case notDetermined
    case denied
    case authorized
}

/// 알림 센터 접근을 감싼 창구. 실제 앱은 시스템 알림 센터를 쓰고, 검증에서는 가짜로 바꿔 끼웁니다.
protocol ReminderCenter {
    func authorization() async -> ReminderAuthorization
    func requestAuthorization() async -> Bool
    func add(_ reminder: PeriodReminder, calendar: Calendar) async throws
    func removePending(withIdentifierPrefix prefix: String) async
    func pendingIdentifiers() async -> [String]
}

/// iOS가 예약해 두었다가 앱이 꺼져 있거나 화면이 잠겨 있어도 정해진 시각에 표시하는 로컬 알림
struct SystemReminderCenter: ReminderCenter {
    /// 알림을 눌렀을 때 어느 회고인지 알기 위해 담는 값의 이름
    static let journalIDKey = "journalID"

    private var center: UNUserNotificationCenter { .current() }

    func authorization() async -> ReminderAuthorization {
        switch await center.notificationSettings().authorizationStatus {
        case .authorized, .provisional, .ephemeral: .authorized
        case .denied: .denied
        case .notDetermined: .notDetermined
        @unknown default: .denied
        }
    }

    func requestAuthorization() async -> Bool {
        (try? await center.requestAuthorization(options: [.alert, .sound])) ?? false
    }

    func add(_ reminder: PeriodReminder, calendar: Calendar) async throws {
        let content = UNMutableNotificationContent()
        content.title = reminder.title
        content.body = reminder.body
        content.sound = .default
        content.userInfo = [Self.journalIDKey: reminder.journalID.uuidString]

        let parts = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: reminder.fireDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: parts, repeats: false)
        try await center.add(UNNotificationRequest(identifier: reminder.identifier, content: content, trigger: trigger))
    }

    func removePending(withIdentifierPrefix prefix: String) async {
        let pending = await center.pendingNotificationRequests()
        let ids = pending.map(\.identifier).filter { $0.hasPrefix(prefix) }
        center.removePendingNotificationRequests(withIdentifiers: ids)
    }

    func pendingIdentifiers() async -> [String] {
        await center.pendingNotificationRequests().map(\.identifier)
    }
}

/// 저장, 수정, 삭제, 설정 변경에 맞춰 종료 알림을 예약하고 취소합니다.
@MainActor
final class PeriodReminderScheduler {
    /// 예약 결과. 사용자에게 알려야 하는 것은 권한 거부와 예약 실패입니다.
    enum Outcome: Equatable {
        case notTarget             // 하루 회고이거나 1단계가 아님 (남은 예약은 취소됨)
        case scheduled(Int)        // 예약한 알림 수
        case nothingToSchedule     // 대상이지만 종료일의 모든 시각이 이미 지남
        case permissionDenied
        case failed

        /// 저장 화면에서 보여 줄 얼럿 문구. 알릴 것이 없으면 nil입니다.
        var alertMessage: String? {
            switch self {
            case .permissionDenied:
                "알림 권한이 꺼져 있어 종료 알림을 예약하지 못했어요. 회고는 저장됐어요. 설정 앱에서 알림을 켠 뒤 다시 저장해 주세요."
            case .failed:
                "종료 알림을 예약하지 못했어요. 회고는 저장됐어요. 잠시 후 다시 저장해 주세요."
            case .notTarget, .scheduled, .nothingToSchedule:
                nil
            }
        }
    }

    static let shared = PeriodReminderScheduler(center: SystemReminderCenter())

    private let center: ReminderCenter
    private var lastOperation: Task<Void, Never> = Task {}

    init(center: ReminderCenter) {
        self.center = center
    }

    /// 회고 저장이 성공한 뒤 부릅니다. 이 회고의 예약을 모두 지우고 현재 값에 맞게 다시 예약합니다.
    /// 대상이 처음 저장될 때 알림 권한을 요청합니다.
    func sync(_ journal: JournalDatabase) async -> Outcome {
        await sync(ReminderSubject(journal), requestPermission: true)
    }

    func sync(
        _ subject: ReminderSubject,
        requestPermission: Bool,
        mode: PeriodEndReminderMode? = nil,
        now: Date = .now,
        calendar: Calendar = .current
    ) async -> Outcome {
        // 설정에 저장된 방식. 검증할 때는 직접 넘길 수 있습니다.
        let mode = mode ?? .current
        return await serialized { [center] in
            let prefix = PeriodReminderPlanner.identifierPrefix(for: subject.id)
            await center.removePending(withIdentifierPrefix: prefix)

            guard subject.isReminderTarget else { return .notTarget }

            var authorization = await center.authorization()
            if authorization == .notDetermined && requestPermission {
                _ = await center.requestAuthorization()
                authorization = await center.authorization()
            }
            guard authorization == .authorized else { return .permissionDenied }

            let reminders = PeriodReminderPlanner.reminders(for: subject, mode: mode, now: now, calendar: calendar)
            guard !reminders.isEmpty else { return .nothingToSchedule }

            do {
                for reminder in reminders {
                    try await center.add(reminder, calendar: calendar)
                }
                return .scheduled(reminders.count)
            } catch {
                await center.removePending(withIdentifierPrefix: prefix)
                return .failed
            }
        }
    }

    /// 회고를 지울 때 남은 예약을 취소합니다.
    func cancel(journalID: UUID) async {
        await serialized { [center] in
            await center.removePending(withIdentifierPrefix: PeriodReminderPlanner.identifierPrefix(for: journalID))
        }
    }

    /// 설정이 바뀌었을 때 모든 대상 회고의 남은 예약에 새 방식을 적용합니다. 권한은 새로 요청하지 않습니다.
    func resyncAll(
        _ journals: [ReminderSubject],
        mode: PeriodEndReminderMode? = nil,
        now: Date = .now,
        calendar: Calendar = .current
    ) async {
        for subject in journals where subject.isReminderTarget {
            _ = await sync(subject, requestPermission: false, mode: mode, now: now, calendar: calendar)
        }
    }

    /// 예약 작업을 들어온 순서대로 하나씩 실행합니다. 저장과 설정 변경이 겹쳐도 예약이 뒤섞이지 않습니다.
    private func serialized<T: Sendable>(_ work: @escaping @MainActor () async -> T) async -> T {
        let previous = lastOperation
        let task = Task { @MainActor () -> T in
            await previous.value
            return await work()
        }
        lastOperation = Task { _ = await task.value }
        return await task.value
    }
}
