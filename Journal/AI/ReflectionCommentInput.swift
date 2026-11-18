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

    var canGenerate: Bool { !body.isEmpty }

    var prompt: String {
        """
        회고 형식: \(format)
        제목: \(title.prefix(200))
        회고 내용:
        \(body.prefix(1600))
        """
    }
}
