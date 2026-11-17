import Foundation

/// 공통 모델의 회고 형식(free, kpt, fourL). 작성 화면에서 쓰기 편하도록 짧은 이름을 붙입니다.
typealias ReflectionFormat = JournalDatabase.ReflectionFormat

/// 작성 화면에서 형식을 보여 주는 방법(이름, 설명, 질문)을 정의합니다.
/// 모델 파일은 건드리지 않고 확장으로만 더합니다.
extension JournalDatabase.ReflectionFormat {
    /// 형식 선택 막대에 보이는 순서 (시안 기준)
    static let displayOrder: [ReflectionFormat] = [.kpt, .fourL, .free]

    var title: String {
        switch self {
        case .kpt: "KPT"
        case .fourL: "4L"
        case .free: "자유"
        }
    }

    /// 형식 설명 박스 문구. 자유 형식은 설명이 없어 nil입니다.
    var guide: String? {
        switch self {
        case .kpt:
            "KPT는 Keep, Problem, Try 세 가지 질문으로 돌아보는 회고예요. 계속할 것과 문제점, 시도할 것을 정리할 때 좋아요."
        case .fourL:
            "4L은 L로 시작하는 네 가지 질문으로 돌아보는 회고예요. 감정과 배움을 함께 정리할 때 좋아요."
        case .free:
            nil
        }
    }

    /// 형식에 속한 질문. 자유 형식은 질문 없이 본문 한 칸을 씁니다.
    var questions: [JournalQuestion] {
        switch self {
        case .kpt:
            [
                JournalQuestion(initial: "K", english: "Keep", korean: "계속할 것", placeholder: "계속하고 싶은 것은?"),
                JournalQuestion(initial: "P", english: "Problem", korean: "문제점", placeholder: "문제였던 부분은?"),
                JournalQuestion(initial: "T", english: "Try", korean: "시도할 것", placeholder: "다음에 시도해 볼 것은?")
            ]
        case .fourL:
            [
                JournalQuestion(initial: "L", english: "Liked", korean: "좋았던 것", placeholder: "좋았던 점은 무엇인가요?"),
                JournalQuestion(initial: "L", english: "Learned", korean: "배운 것", placeholder: "새로 배운 것은?"),
                JournalQuestion(initial: "L", english: "Lacked", korean: "부족했던 것", placeholder: "더 연습이 필요한 부분은?"),
                JournalQuestion(initial: "L", english: "Longed for", korean: "바랐던 것", placeholder: "있었으면 좋았을 것은?")
            ]
        case .free:
            []
        }
    }
}

/// 질문 한 줄의 표시 정보
struct JournalQuestion: Identifiable {
    /// 아이콘에 쓰는 한 글자 (K, P, T, L)
    let initial: String
    let english: String
    let korean: String
    let placeholder: String

    /// 모델의 ReflectionAnswer.question에 저장하는 값
    var id: String { english }
}
