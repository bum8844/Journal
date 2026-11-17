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
