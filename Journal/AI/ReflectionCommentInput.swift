import Foundation

/// AI 한마디를 만들 때 모델에 넘기는 입력. 공백을 정리하고, 너무 긴 글은 잘라서 프롬프트로 만든다.
struct ReflectionCommentInput: Equatable {
    let format: String
    let title: String
    let body: String

    init(format: String, title: String, body: String) {
        self.format = format
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.body = body.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// 본문이 비어 있으면 생성할 수 없다.
    var canGenerate: Bool { !body.isEmpty }

    /// 모델에 보낼 프롬프트. 제목은 200자, 본문은 1600자까지만 쓴다.
    var prompt: String {
        """
        회고 형식: \(format)
        제목: \(title.prefix(200))
        회고 내용:
        \(body.prefix(1600))
        """
    }
}
