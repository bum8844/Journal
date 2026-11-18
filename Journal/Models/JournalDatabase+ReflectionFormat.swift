//
//  JournalDatabase+ReflectionFormat.swift
//  Journal
//
//  Created by IOS EST on 11/17/26.
//

import Foundation

// 회고 형식과 질문별 답변의 타입 정의, 그리고 날짜 계산 프로퍼티.
// 이 확장에는 값을 저장하는 필드를 두지 않는다. 저장 필드(format, answers 등)는
// 확장에 둘 수 없어서 JournalDatabase.swift의 클래스 본문에 있다.
extension JournalDatabase {
    enum ReflectionFormat: String, Codable, CaseIterable {
        case free
        // 기존 회고의 저장값과 호환되도록 UI 이름만 바꾼다.
        case tomorrow = "kpt"
        case fourL

        init(from decoder: Decoder) throws {
            let value = try decoder.singleValueContainer()
            let name = try value.decode(String.self)
            if name == "tomorrow" {
                self = .tomorrow
            } else if let format = Self(rawValue: name) {
                self = format
            } else {
                throw DecodingError.dataCorruptedError(in: value, debugDescription: "Unknown reflection format: \(name)")
            }
        }
    }

    /// 형식 필드가 추가되기 전에 저장된 회고는 자유 형식으로 열린다.
    var effectiveFormat: ReflectionFormat { format ?? .free }
    
    struct ReflectionAnswer: Codable, Hashable {
        var question: String   // 예: "Keep"
        var text: String
    }
    
    /// 회고 대상 날짜. 날짜 규칙을 한 곳에서 정하기 위한 값이다.
    /// - 하루 회고: 선택한 날짜(startDate)
    /// - 기간 회고: 시작일(startDate)
    /// - 날짜가 저장되지 않은 기존 글: 최초 작성일(createdAt)
    /// 목록 정렬, 상세 표시, 통계 기준을 바꿀 때는 각자 계산하지 말고 이 값을 쓴다.
    /// (지금 목록 정렬과 통계는 아직 createdAt을 쓴다. 기준 변경은 팀 합의 후에 한다.)
    var reviewDate: Date { startDate ?? createdAt }
}
