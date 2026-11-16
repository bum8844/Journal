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
