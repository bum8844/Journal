import Foundation

/// 회고 모델에서 기간별 집계에 필요한 값만 전달합니다.
struct StatisticsEntry {
    let createdAt: Date
    let tags: [String]
}

/// 한 태그가 붙은 회고 수입니다. 태그 문자열을 목록 항목의 고유 식별자로 사용합니다.
struct TagCount: Identifiable, Equatable {
    let tag: String
    let count: Int

    var id: String { tag }
}

/// 선택한 기간의 회고 수와 태그별 회고 수를 집계합니다.
struct ReflectionStatistics {
    let reflectionCount: Int
    let tagCounts: [TagCount]

    /// 시작 시각을 포함하고 끝 시각을 제외해 인접한 주나 달에 같은 기록을 두 번 세지 않습니다.
    init(entries: [StatisticsEntry], interval: DateInterval) {
        let periodEntries = entries.filter {
            interval.start <= $0.createdAt && $0.createdAt < interval.end
        }
        // 태그가 없는 회고도 전체 회고 건수에는 포함됩니다.
        reflectionCount = periodEntries.count

        // 키는 태그 이름, 값은 그 태그가 붙은 회고 수입니다.
        var counts: [String: Int] = [:]
        for entry in periodEntries {
            // 앞뒤 공백을 제거하고 Set으로 중복을 없애 같은 글의 동일 태그를 한 번만 셉니다.
            let tags = Set(entry.tags.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) })
            for tag in tags where !tag.isEmpty {
                counts[tag, default: 0] += 1
            }
        }

        // 자주 쓴 태그부터 표시합니다. 건수가 같으면 태그 문자열로 순서를 정합니다.
        tagCounts = counts.map { TagCount(tag: $0.key, count: $0.value) }.sorted {
            if $0.count == $1.count {
                return $0.tag < $1.tag
            }
            return $0.count > $1.count
        }
    }
}
