import Foundation
import SwiftData

// 팀 공통 모델 `JournalDatabase`(JournalDatabase.swift)에 분류·필터 기능을 더하는 확장입니다.
// 모델 자체의 프로퍼티는 바꾸지 않습니다.
extension JournalDatabase {
    /// 카테고리 입력값의 앞뒤 공백을 제거하고, 빈 값이면 nil을 반환합니다.
    static func normalizedCategory(_ raw: String) -> String? {
        let text = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        return text.isEmpty ? nil : JournalCategory.normalized(text)
    }

    /// 태그 입력값을 정리합니다. 공백과 앞의 `#`을 제거하고, 빈 값이면 nil을 반환합니다.
    static func normalizedTag(_ raw: String) -> String? {
        JournalTag.normalized(raw)
    }

    /// 기존 태그 뒤에 새 태그를 붙입니다. 입력이 비었거나 이미 있으면 그대로 돌려줍니다.
    static func tags(_ tags: [String], adding raw: String) -> [String] {
        guard let tag = normalizedTag(raw), !tags.contains(tag) else { return tags }
        return tags + [tag]
    }

    /// 카테고리와 태그 필터를 적용합니다.
    /// - 카테고리가 같고 선택한 태그를 모두 가진 항목만 남깁니다.
    /// - withoutTags는 실제 태그가 없는 글만 남깁니다. 카테고리 조건도 함께 적용됩니다.
    /// - 카테고리가 nil이고 태그가 비어 있으며 withoutTags가 false면 전체를 돌려줍니다.
    static func filter(
        _ items: [JournalDatabase],
        category: String?,
        tags: Set<String>,
        withoutTags: Bool = false
    ) -> [JournalDatabase] {
        items.filter { item in
            let matchesCategory = category.map { JournalCategory.normalized($0) == JournalCategory.normalized(item.category) } ?? true
            let matchesTags = withoutTags
                ? JournalTag.hasNone(item.tags)
                : tags.isSubset(of: item.tags)
            return matchesCategory && matchesTags
        }
    }
}
