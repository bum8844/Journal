//
//  JournalDaySection.swift
//  Journal
//
//  목록을 작성일(createdAt) 기준으로 나누는 구간. 구간 제목은 "오늘", "어제", "11월 17일"처럼 보인다.
//

import Foundation

struct JournalDaySection: Identifiable {
    /// 구간의 날짜(그날 0시). 구간을 구분하는 값으로도 쓴다.
    let day: Date
    let journals: [JournalDatabase]

    var id: Date { day }

    /// 구간 제목. 오늘과 어제는 이름으로, 올해는 "11월 17일", 지난해 이전은 "2025년 11월 17일"로 보여 준다.
    func title(now: Date = .now, calendar: Calendar = .current) -> String {
        if calendar.isDate(day, inSameDayAs: now) { return "오늘" }
        if let yesterday = calendar.date(byAdding: .day, value: -1, to: now),
           calendar.isDate(day, inSameDayAs: yesterday) { return "어제" }

        let sameYear = calendar.isDate(day, equalTo: now, toGranularity: .year)
        let style = sameYear
            ? Date.FormatStyle().month().day()
            : Date.FormatStyle().year().month().day()
        // 기기 언어와 상관없이 한국어로 표시한다 (Date+Korean.swift와 같은 방식)
        return day.formatted(style.locale(Locale(identifier: "ko_KR")))
    }

    /// 받은 순서를 그대로 두고, 같은 날 작성한 글끼리 묶는다.
    /// 최신순으로 정렬된 목록을 받으면 구간도 최신순이 된다.
    static func sections(
        from journals: [JournalDatabase],
        calendar: Calendar = .current
    ) -> [JournalDaySection] {
        var result: [JournalDaySection] = []
        for journal in journals {
            let day = calendar.startOfDay(for: journal.createdAt)
            if let last = result.last, last.day == day {
                result[result.count - 1] = JournalDaySection(day: day, journals: last.journals + [journal])
            } else {
                result.append(JournalDaySection(day: day, journals: [journal]))
            }
        }
        return result
    }
}
