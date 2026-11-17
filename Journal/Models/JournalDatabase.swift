//
//  JournalDatabase.swift
//  Journal
//
//  Created by IOS EST on 11/16/26.
//

import Foundation
import SwiftData

@Model

final class JournalDatabase: Identifiable {
    var id = UUID()
    var title: String
    var content: String
    var createdAt = Date()
    var category: String
    var tags: [String]
    
    // 시안 B에서 추가한 필드. 모두 기본값 또는 선택값이라 기존 글은
    // "자유 형식, 하루 회고, 사진 없음"으로 열린다.
    // 저장 프로퍼티는 확장(extension)에 둘 수 없어서 클래스 본문에 둔다.
    // 타입 정의(ReflectionFormat, ReflectionAnswer)는 JournalDatabase+ReflectionFormat.swift에 있다.
    var format: ReflectionFormat = ReflectionFormat.free   // 회고 형식 (자유 / KPT / 4L)
    var answers: [ReflectionAnswer] = []                   // 질문별 답변 (KPT, 4L일 때 사용)
    var isPeriod: Bool = false                             // false = 하루 회고, true = 기간 회고
    var startDate: Date?                                   // 기간 시작일
    var endDate: Date?                                     // 기간 종료일
    @Attribute(.externalStorage) var photoData: Data?      // 사진 한 장
    
    // 새 매개변수는 모두 기본값이 있어서 기존 호출(title, content, category, tags)은 그대로 쓸 수 있다.
    init(
        title: String,
        content: String,
        category: String,
        tags: [String],
        format: ReflectionFormat = .free,
        answers: [ReflectionAnswer] = [],
        isPeriod: Bool = false,
        startDate: Date? = nil,
        endDate: Date? = nil,
        photoData: Data? = nil
    ) {
        self.title = title
        self.content = content
        self.category = category
        self.tags = tags
        self.format = format
        self.answers = answers
        self.isPeriod = isPeriod
        self.startDate = startDate
        self.endDate = endDate
        self.photoData = photoData
    }
}

// MARK: - 샘플 데이터 (프리뷰와 개발 중 확인용, 위 모델 정의는 수정하지 않음)

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
