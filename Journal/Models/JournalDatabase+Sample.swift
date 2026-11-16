//
//  JournalDatabase+Sample.swift
//  Journal
//
//  프리뷰 확인용 샘플 데이터 (실제 앱 빌드에는 포함되지 않는다)
//

#if DEBUG
import Foundation

extension JournalDatabase {
    static var samples: [JournalDatabase] {
        [
            JournalDatabase(title: "교육", content: "오늘 배운 SwiftUI 정리", category: "교육", tags: ["교육"]),
            JournalDatabase(title: "오늘 할일", content: "장보기, 청소, 빨래", category: "할일", tags: ["할일"]),
            JournalDatabase(title: "요리", content: "김치볶음밥 만들기", category: "요리", tags: ["요리"]),
            JournalDatabase(title: "운동", content: "러닝 5km 완료", category: "운동", tags: ["운동"])
        ]
    }
}
#endif
