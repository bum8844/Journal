//
//  JournalDatabase+ReflectionFormat.swift
//  Journal
//
//  Created by IOS EST on 11/17/26.
//

import Foundation

// 회고 형식과 질문별 답변의 타입 정의.
// 이 확장에는 타입만 둔다. 값을 저장하는 필드(format, answers 등)는
// 확장에 둘 수 없어서 JournalDatabase.swift의 클래스 본문에 있다.
extension JournalDatabase {
    enum ReflectionFormat: String, Codable, CaseIterable { case free, tomorrow, fourL }
    
    struct ReflectionAnswer: Codable, Hashable {
        var question: String   // 예: "내일 해볼 한 가지"
        var text: String
    }
}
