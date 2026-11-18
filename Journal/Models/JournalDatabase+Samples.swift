//
//  JournalDatabase+Samples.swift
//  Journal
//
//  프리뷰와 개발 중 확인용 샘플 데이터. 모델 정의(JournalDatabase.swift)와 분리해 둔다.
//

import Foundation
import SwiftData

extension JournalDatabase {
    static var samples: [JournalDatabase] {
        let items = [
            JournalDatabase(title: "교육", content: "오늘 배운 SwiftUI 정리", category: "교육", tags: ["교육"]),
            JournalDatabase(title: "오늘 할일", content: "장보기, 청소, 빨래", category: "할일", tags: ["할일"]),
            JournalDatabase(title: "요리", content: "김치볶음밥 만들기", category: "요리", tags: ["요리"]),
            JournalDatabase(title: "운동", content: "러닝 5km 완료", category: "운동", tags: ["운동"]),
            JournalDatabase(title: "요리", content: "순두부찌개 만들기", category: "요리", tags: ["요리"]),
            JournalDatabase(title: "운동", content: "숨쉬기 운동", category: "운동", tags: ["운동"]),
            JournalDatabase(title: "오늘 할일", content: "화장실 청소하기", category: "할일", tags: ["할일"]),
            JournalDatabase(title: "운동", content: "배드민턴 하기", category: "운동", tags: ["운동"])
        ]
        // 최신순 정렬에서 순서가 고정되도록 작성 시각을 1분씩 어긋나게 한다
        for (index, item) in items.enumerated() {
            item.createdAt = Date().addingTimeInterval(-Double(index) * 60)
        }
        return items
    }
}
