import Foundation

/// 저장·목록 필터·통계에서 같은 기준으로 태그 유무를 판단합니다.
enum JournalTag {
    // 문자열 계산만 하므로 UI를 담당하는 MainActor에 묶일 필요가 없습니다.
    nonisolated static func normalized(_ raw: String) -> String? {
        var text = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        while text.hasPrefix("#") { text.removeFirst() }
        text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return text.isEmpty ? nil : text
    }

    nonisolated static func hasNone(_ tags: [String]) -> Bool {
        tags.allSatisfy { normalized($0) == nil }
    }
}
