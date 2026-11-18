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
    
    // 시안 B 이전 회고에는 format 값이 없으므로 옵셔널로 읽는다.
    // 새 회고는 생성 시 형식을 저장하고, 기존 회고의 빈 값은 effectiveFormat에서 자유 형식으로 처리한다.
    // 저장 프로퍼티는 확장(extension)에 둘 수 없어서 클래스 본문에 둔다.
    // 타입 정의(ReflectionFormat, ReflectionAnswer)는 JournalDatabase+ReflectionFormat.swift에 있다.
    var format: ReflectionFormat?                          // 회고 형식 (자유 / KPT / 4L)
    var answers: [ReflectionAnswer] = []                   // 질문별 답변 (KPT, 4L일 때 사용)
    var isPeriod: Bool = false                             // false = 하루 회고, true = 기간 회고
    var startDate: Date?                                   // 기간 시작일
    var endDate: Date?                                     // 기간 종료일
    @Attribute(.externalStorage) var photoData: Data?      // 사진 한 장
    // 중요도. 1(높음)인 기간 회고만 종료일 알림을 받는다.
    // 이전 버전에서 저장한 글에는 값이 없어서 옵셔널로 둔다. (필수 값으로 두면 옛 글을 읽을 때 앱이 꺼진다)
    // 값이 없으면 2(보통)로 취급하니, 읽을 때는 `effectiveImportance`를 쓴다.
    var importance: ReflectionImportance?
    var aiComment: String?
    
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
        photoData: Data? = nil,
        importance: ReflectionImportance = .normal
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
        self.importance = importance
    }
}
