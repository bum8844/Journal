import Foundation
import SwiftData

/// 회고 중요도. 1단계(높음)인 기간 회고만 종료일 알림을 받습니다.
/// 원시값(1, 2, 3)이 저장되므로 숫자를 바꾸지 않습니다.
enum ReflectionImportance: Int, Codable, CaseIterable {
    case high = 1
    case normal = 2
    case low = 3

    /// 선택 막대에 보이는 이름
    var title: String {
        switch self {
        case .high: "1 · 높음"
        case .normal: "2 · 보통"
        case .low: "3 · 낮음"
        }
    }

    /// 목록 카드 배지에 보이는 짧은 이름
    var shortTitle: String {
        switch self {
        case .high: "높음"
        case .normal: "보통"
        case .low: "낮음"
        }
    }
}

extension JournalDatabase {
    /// 화면과 알림이 읽는 중요도. 중요도가 저장되지 않은 기존 글은 2단계(보통)입니다.
    var effectiveImportance: ReflectionImportance { importance ?? .normal }
}
