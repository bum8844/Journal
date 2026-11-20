import Foundation

/// 저장·표시·필터·통계가 같은 카테고리 이름을 사용합니다.
enum JournalCategory {
    static let unclassified = "분류없음"

    static func normalized(_ value: String) -> String {
        let category = value.trimmingCharacters(in: .whitespacesAndNewlines)
        // 기존 글의 빈 값과 이전 표시 이름도 같은 항목으로 묶습니다. DB 일괄 변경은 필요 없습니다.
        return category.isEmpty || category == "미분류" ? unclassified : category
    }

    static func title(for value: String) -> String {
        normalized(value)
    }
}
