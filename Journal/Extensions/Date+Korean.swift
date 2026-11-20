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
    /// 화면에 보여 줄 날짜. 기간 회고는 "2026년 11월 16일 ~ 2026년 11월 18일", 하루 회고는 선택일입니다. 값이 없으면 작성일로 대체합니다.
    var displayDateString: String {
        if isPeriod, let startDate, let endDate {
            return "\(startDate.koreanDateString) ~ \(endDate.koreanDateString)"
        }
        return reviewDate.koreanDateString
    }
}
