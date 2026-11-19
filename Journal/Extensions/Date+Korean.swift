//
//  Date+Korean.swift
//  Journal
//
//  기기 언어와 상관없이 날짜를 한국어로 표시한다. 예: 2026년 11월 16일
//

import Foundation

extension Date {
    var koreanDateString: String {
        formatted(
            Date.FormatStyle(date: .long, time: .omitted)
                .locale(Locale(identifier: "ko_KR"))
        )
    }
}

extension JournalDatabase {
    /// 화면에 보여 줄 날짜. 기간 회고는 "2026년 11월 16일 ~ 2026년 11월 18일", 하루 회고는 작성일입니다.
    var displayDateString: String {
        if isPeriod, let startDate, let endDate {
            return "\(startDate.koreanDateString) ~ \(endDate.koreanDateString)"
        }
        return createdAt.koreanDateString
    }

    /// 목록 카드에 보여 줄 날짜. 없으면 nil이라 카드에는 날짜 줄이 나오지 않는다.
    /// - 기간 회고: "시작일 ~ 종료일"
    /// - 하루 회고: 목록 구간 제목이 작성일을 이미 보여 주므로 생략한다.
    ///   단, 고른 날짜가 작성일과 다르면 "2026년 10월 9일 회고"로 알려 준다.
    var listDateText: String? {
        if isPeriod, let startDate, let endDate {
            return "\(startDate.koreanDateString) ~ \(endDate.koreanDateString)"
        }
        guard !isPeriod, let startDate,
              !Calendar.current.isDate(startDate, inSameDayAs: createdAt) else { return nil }
        return "\(startDate.koreanDateString) 회고"
    }
}
