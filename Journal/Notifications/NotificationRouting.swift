import Foundation
import Observation
import UserNotifications

/// 알림을 눌렀을 때 열어야 할 회고를 화면에 전달합니다.
/// 앱이 꺼져 있다가 알림으로 켜지는 경우에도 값이 남아 있어서, 화면이 준비된 뒤 읽어 갑니다.
@MainActor
@Observable
final class NotificationRouter {
    static let shared = NotificationRouter()

    /// 열어야 할 회고의 id. 화면이 열고 나면 nil로 돌려 둡니다.
    var pendingJournalID: UUID?
}

/// 알림 센터의 이벤트(앱을 쓰는 중 도착, 알림 누름)를 받는 담당입니다.
final class NotificationCoordinator: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationCoordinator()

    /// 앱을 사용하는 중에도 배너로 알림을 보여 줍니다.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .list, .sound]
    }

    /// 알림을 누르면 해당 회고의 상세 화면을 엽니다.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let userInfo = response.notification.request.content.userInfo
        guard let text = userInfo[SystemReminderCenter.journalIDKey] as? String,
              let id = UUID(uuidString: text) else { return }
        await MainActor.run { NotificationRouter.shared.pendingJournalID = id }
    }
}
