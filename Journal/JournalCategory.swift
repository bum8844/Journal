import Foundation

/// 빈 카테고리와 사용자가 직접 입력한 "미분류"를 구분하는 공통 표시 규칙입니다.
enum JournalCategory {
    static func normalized(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func title(for value: String) -> String {
        let category = normalized(value)
        if category.isEmpty { return "미분류" }
        return category == "미분류" ? "미분류 (직접 입력)" : category
    }
}
