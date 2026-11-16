//
//  JournalDatabase+Sample.swift
//  Journal
//
//  프리뷰와 개발 중 확인용 샘플 데이터
//

import Foundation
import SwiftData

extension JournalDatabase {
    static var samples: [JournalDatabase] {
        let items = [
            JournalDatabase(title: "교육", content: "오늘 배운 SwiftUI 정리", category: "교육", tags: ["교육"]),
            JournalDatabase(title: "오늘 할일", content: "장보기, 청소, 빨래", category: "할일", tags: ["할일"]),
            JournalDatabase(title: "요리", content: "김치볶음밥 만들기", category: "요리", tags: ["요리"]),
            JournalDatabase(title: "운동", content: "러닝 5km 완료", category: "운동", tags: ["운동"])
        ]
        // 최신순 정렬에서 순서가 고정되도록 작성 시각을 1분씩 어긋나게 한다
        for (index, item) in items.enumerated() {
            item.createdAt = Date().addingTimeInterval(-Double(index) * 60)
        }
        return items
    }
}

#if DEBUG
extension JournalDatabase {
    private static let seededKey = "didSeedSampleJournals"

    /// 앱을 처음 실행할 때 한 번만 샘플을 넣는다. (DEBUG 빌드에서만 사용)
    /// 이후에 전부 삭제해도 다시 넣지 않는다. 삭제가 유지되는지 확인하기 위해서다.
    @MainActor
    static func seedSamplesIfNeeded(in context: ModelContext) {
        guard !UserDefaults.standard.bool(forKey: seededKey) else { return }
        samples.forEach { context.insert($0) }
        try? context.save()
        UserDefaults.standard.set(true, forKey: seededKey)
    }
}
#endif
