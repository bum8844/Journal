import Foundation

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

    var prompt: String {
        """
        회고 형식: \(format)
        제목: \(title.prefix(200))
        회고 내용:
        \(body.prefix(1600))
        """
    }
}
