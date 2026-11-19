import Foundation

/// 회고 모델에서 기간별 집계에 필요한 값만 전달합니다.
struct StatisticsEntry {
    let createdAt: Date
    let tags: [String]
    let category: String
    let isPeriod: Bool
    let hasPhoto: Bool
    var endDate: Date? = nil
    var importance: Int = 2
    var startDate: Date? = nil
}

/// 한 태그가 붙은 회고 수입니다. 태그 문자열을 목록 항목의 고유 식별자로 사용합니다.
struct TagCount: Identifiable, Equatable {
    let tag: String
    let count: Int

    var id: String { tag }
}

struct DailyReflectionCount: Identifiable {
    let date: Date
    let count: Int

    var id: Date { date }
}

struct CategoryCount: Identifiable {
    let category: String
    let count: Int

    var id: String { category }
    var name: String { JournalCategory.title(for: category) }
}

/// 선택한 기간의 회고를 날짜, 종류, 사진 첨부, 태그와 카테고리별로 집계합니다.
struct ReflectionStatistics {
    /// 기기의 시간대는 유지하되 주간 회고는 월요일부터 일요일까지 묶습니다.
    static func reportingCalendar(from calendar: Calendar) -> Calendar {
        var result = calendar
        result.firstWeekday = 2
        return result
    }

    let reflectionCount: Int
    let periodCount: Int
    let photoCount: Int
    let endedPeriodCount: Int
    let ongoingPeriodCount: Int
    let upcomingPeriodCount: Int
    let undatedPeriodCount: Int
    let importanceCounts: [Int]

    var singleDayCount: Int { reflectionCount - periodCount }
    let tagCounts: [TagCount]
    let dailyCounts: [DailyReflectionCount]
    let categoryCounts: [CategoryCount]

    /// 시작 시각을 포함하고 끝 시각을 제외해 인접한 주나 달에 같은 기록을 두 번 세지 않습니다.
    init(entries: [StatisticsEntry], interval: DateInterval, calendar: Calendar, now: Date = .now) {
        let periodEntries = entries.filter {
            interval.start <= $0.createdAt && $0.createdAt < interval.end
        }
        // 태그가 없는 회고도 전체 회고 건수에는 포함됩니다.
        reflectionCount = periodEntries.count
        // 기간에 걸친 날짜 수와 무관하게 회고 한 개를 한 건으로 셉니다.
        periodCount = periodEntries.count(where: \.isPeriod)
        photoCount = periodEntries.count(where: \.hasPhoto)

        // 시작 전은 예정, 시작일부터 종료일 당일까지는 진행 중으로 구분합니다.
        // 종료는 작업 완료 판정과 별개이며, 시작일이 없는 옛 글은 작성일을 대신 사용합니다.
        let today = calendar.startOfDay(for: now)
        var upcoming = 0
        var ongoing = 0
        var ended = 0
        var undated = 0
        for entry in periodEntries where entry.isPeriod {
            guard let endDate = entry.endDate else {
                undated += 1
                continue
            }
            if calendar.startOfDay(for: endDate) < today {
                ended += 1
            } else if calendar.startOfDay(for: entry.startDate ?? entry.createdAt) > today {
                upcoming += 1
            } else {
                ongoing += 1
            }
        }
        upcomingPeriodCount = upcoming
        ongoingPeriodCount = ongoing
        endedPeriodCount = ended
        undatedPeriodCount = undated
        importanceCounts = (1...3).map { level in
            periodEntries.count { $0.importance == level }
        }

        // 기록이 없는 날도 0건으로 채워 날짜 순서와 간격을 유지합니다.
        let entriesByDay = Dictionary(grouping: periodEntries) { calendar.startOfDay(for: $0.createdAt) }
        var days: [DailyReflectionCount] = []
        var day = calendar.startOfDay(for: interval.start)
        while day < interval.end {
            days.append(DailyReflectionCount(date: day, count: entriesByDay[day]?.count ?? 0))
            guard let nextDay = calendar.date(byAdding: .day, value: 1, to: day), nextDay > day else { break }
            day = nextDay
        }
        dailyCounts = days

        // 카테고리가 없는 회고도 비율의 분모에 포함합니다.
        let entriesByCategory = Dictionary(grouping: periodEntries) { entry in
            JournalCategory.normalized(entry.category)
        }
        categoryCounts = entriesByCategory.map { CategoryCount(category: $0.key, count: $0.value.count) }.sorted {
            if $0.count == $1.count {
                return $0.name < $1.name
            }
            return $0.count > $1.count
        }

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
