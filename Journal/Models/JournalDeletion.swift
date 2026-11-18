import Foundation
import SwiftData

/// 회고 삭제. 목록 스와이프 삭제와 상세 화면 삭제가 같은 규칙을 쓰도록 한곳에 모았습니다.
enum JournalDeletion {
    /// 삭제 실패 때 보여 줄 얼럿 문구
    static let failureMessage = "회고를 삭제하지 못했어요. 다시 시도해 주세요."

    /// 회고를 지우고 저장합니다.
    /// - 저장이 성공하면 true입니다. 종료 알림 정리는 이 값이 true일 때만 하세요.
    /// - 저장이 실패하면 `rollback()`으로 삭제를 되돌려 회고를 그대로 두고 false를 돌려줍니다.
    ///   이때는 알림을 건드리지 않아 기존 예약이 유지됩니다.
    /// - Parameter save: 저장 동작. 기본값은 `context.save()`이고, 검증에서는 실패를 흉내 내려고 바꿔 끼웁니다.
    @MainActor
    static func delete(
        _ journal: JournalDatabase,
        in context: ModelContext,
        save: (ModelContext) throws -> Void = { try $0.save() }
    ) -> Bool {
        context.delete(journal)
        do {
            try save(context)
            return true
        } catch {
            context.rollback()
            return false
        }
    }
}
