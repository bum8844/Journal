import Foundation

/// 회고 모델에서 월별 집계에 필요한 값만 전달합니다.
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

/// 선택한 월의 회고 수와 태그별 회고 수를 집계합니다.
struct MonthlyStatistics {
    let reflectionCount: Int
    let tagCounts: [TagCount]

    /// 전달받은 달력으로 작성일과 선택한 달의 연·월을 비교하고, 회고 건수와 태그 빈도를 계산합니다.
    init(entries: [StatisticsEntry], month: Date, calendar: Calendar) {
        let monthlyEntries = entries.filter {
            calendar.isDate($0.createdAt, equalTo: month, toGranularity: .month)
        }
        // 태그가 없는 회고도 전체 회고 건수에는 포함됩니다.
        reflectionCount = monthlyEntries.count

        // 키는 태그 이름, 값은 그 태그가 붙은 회고 수입니다.
        var counts: [String: Int] = [:]
        for entry in monthlyEntries {
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
