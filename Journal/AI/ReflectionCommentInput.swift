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

    /// 자음·모음이나 기호만으로는 회고 내용을 알 수 없어 모델에 보내지 않습니다.
    /// 한국어 완성 글자뿐 아니라 영문 등 다른 언어의 글자도 허용합니다.
    var canGenerate: Bool {
        body.unicodeScalars.contains { scalar in
            CharacterSet.letters.contains(scalar)
                && !(0x1100...0x11FF).contains(scalar.value)
                && !(0x3130...0x318F).contains(scalar.value)
        }
    }

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
