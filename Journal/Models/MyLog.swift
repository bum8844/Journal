import Foundation
import SwiftData

/// 마이로그 한 건. SwiftData에 저장되는 모델입니다.
@Model
final class MyLog {
    var title: String
    var content: String
    /// 최초 작성일. 편집해도 바꾸지 않습니다. 주·월별 통계에 사용합니다.
    var createdAt: Date
    /// 카테고리 한 개
    var category: String
    /// 태그 여러 개. 없으면 빈 배열
    var tags: [String]

    init(
        title: String,
        content: String,
        createdAt: Date = .now,
        category: String,
        tags: [String] = []
    ) {
        self.title = title
        self.content = content
        self.createdAt = createdAt
        self.category = category
        self.tags = tags
    }
}

extension MyLog {
    /// 카테고리 입력값의 앞뒤 공백을 제거하고, 빈 값이면 nil을 반환합니다.
    static func normalizedCategory(_ raw: String) -> String? {
        let text = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        return text.isEmpty ? nil : text
    }

    /// 태그 입력값을 정리합니다. 공백과 앞의 `#`을 제거하고, 빈 값이면 nil을 반환합니다.
    static func normalizedTag(_ raw: String) -> String? {
        var text = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        while text.hasPrefix("#") { text.removeFirst() }
        text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return text.isEmpty ? nil : text
    }

    /// 기존 태그 뒤에 새 태그를 붙입니다. 입력이 비었거나 이미 있으면 그대로 돌려줍니다.
    static func tags(_ tags: [String], adding raw: String) -> [String] {
        guard let tag = normalizedTag(raw), !tags.contains(tag) else { return tags }
        return tags + [tag]
    }

    /// 검색어와 필터를 적용합니다.
    /// - 카테고리가 같고 선택한 태그를 모두 가진 항목만 남깁니다.
    /// - 검색어는 제목, 본문, 카테고리, 태그에서 대소문자와 상관없이 찾습니다.
    ///   공백으로 나눈 단어를 모두 포함해야 하며, 검색어가 비어 있으면 검색을 적용하지 않습니다.
    /// - 카테고리가 nil, 태그가 비어 있고 검색어도 없으면 전체를 그대로 돌려줍니다.
    static func filter(
        _ logs: [MyLog],
        category: String?,
        tags: Set<String>,
        query: String = ""
    ) -> [MyLog] {
        let words = query.split(whereSeparator: \.isWhitespace).map(String.init)
        return logs.filter { log in
            let matchesCategory = category.map { $0 == log.category } ?? true
            return matchesCategory && tags.isSubset(of: log.tags) && log.matches(words)
        }
    }

    /// 모든 검색 단어가 제목, 본문, 카테고리, 태그 중 어디에든 들어 있는지 확인합니다.
    private func matches(_ words: [String]) -> Bool {
        let fields = [title, content, category] + tags
        return words.allSatisfy { word in
            fields.contains { $0.localizedStandardContains(word) }
        }
    }
}
