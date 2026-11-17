import Foundation

/// 공통 모델의 회고 형식(free, tomorrow, fourL). 작성 화면에서 쓰기 편하도록 짧은 이름을 붙입니다.
typealias ReflectionFormat = JournalDatabase.ReflectionFormat

/// 작성 화면에서 형식을 보여 주는 방법(이름, 질문)을 정의합니다.
/// 모델 파일은 건드리지 않고 확장으로만 더합니다.
extension JournalDatabase.ReflectionFormat {
    /// 형식 선택 탭에 보이는 순서 (시안 기준: 오늘의 경험, 내일을 위한 정리, 자유)
    static let displayOrder: [ReflectionFormat] = [.fourL, .tomorrow, .free]

    /// 형식 선택 탭에 보이는 이름
    var title: String {
        switch self {
        case .fourL: "오늘의 경험"
        case .tomorrow: "내일을 위한 정리"
        case .free: "자유"
        }
    }

    /// 형식에 속한 질문. 자유 형식은 질문 없이 본문 한 칸을 씁니다.
    var questions: [JournalQuestion] {
        switch self {
        case .fourL:
            // 질문 이름(key)은 제목과 같습니다. 제목을 바꾸면 이미 저장된 답변과 연결이 끊기니 주의하세요.
            [
                JournalQuestion(key: "좋았던 점", title: "좋았던 점", legacyKey: "Liked", placeholder: "오늘 어떤 순간에 기분이 좋았나요?"),
                JournalQuestion(key: "배운 점", title: "배운 점", legacyKey: "Learned", placeholder: "새롭게 알게 되거나 깨달은 게 있나요?"),
                JournalQuestion(key: "아쉬웠던 점", title: "아쉬웠던 점", legacyKey: "Lacked", placeholder: "조금 아쉽게 느껴진 순간이 있었나요?"),
                JournalQuestion(key: "바라는 점", title: "바라는 점", legacyKey: "Longed for", placeholder: "앞으로 어떤 순간이 더 많아지면 좋을까요?")
            ]
        case .tomorrow:
            // 시안의 질문은 임시 문구입니다. 확정되면 이 세 줄만 바꾸면 됩니다.
            // 질문 이름(key)은 제목과 같습니다. 제목을 바꾸면 이미 저장된 답변과 연결이 끊기니 주의하세요.
            [
                JournalQuestion(key: "내일 해볼 한 가지", title: "내일 해볼 한 가지", legacyKey: "Try", placeholder: "내일 가장 먼저 해보고 싶은 건 뭔가요?"),
                JournalQuestion(key: "미리 챙길 것", title: "미리 챙길 것", legacyKey: "Problem", placeholder: "내일을 위해 준비하면 좋은 게 있나요?"),
                JournalQuestion(key: "내일의 나에게", title: "내일의 나에게", legacyKey: "Keep", placeholder: "내일의 나에게 한마디 남겨볼까요?")
            ]
        case .free:
            []
        }
    }
}

/// 질문 한 줄의 표시 정보
struct JournalQuestion: Identifiable {
    /// 모델의 ReflectionAnswer.question에 저장하는 값. 이미 저장된 글과 연결되므로 함부로 바꾸지 않습니다.
    let key: String
    /// 작성 화면 질문 카드의 굵은 제목. 목록·상세의 본문(content)에도 질문 이름으로 들어갑니다.
    let title: String
    /// 이전 KPT·4L 회고에 저장된 질문 이름.
    let legacyKey: String
    /// 제목 아래에 흐리게 보이는 안내 문구. 입력을 시작하면 사라집니다.
    let placeholder: String

    var id: String { key }
}
