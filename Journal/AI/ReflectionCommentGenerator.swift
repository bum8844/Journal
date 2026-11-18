import Foundation
import FoundationModels

enum ReflectionCommentGenerator {
    static var unavailableMessage: String? {
        let model = SystemLanguageModel.default
        switch model.availability {
        case .available:
            return model.supportsLocale(Locale(identifier: "ko-KR"))
                ? nil : "이 기기의 Apple Intelligence 모델은 한국어 생성을 지원하지 않아요."
        case .unavailable(.deviceNotEligible):
            return "이 기기에서는 AI 한마디를 사용할 수 없어요."
        case .unavailable(.appleIntelligenceNotEnabled):
            return "기기 설정에서 Apple Intelligence를 켜면 사용할 수 있어요."
        case .unavailable(.modelNotReady):
            return "Apple Intelligence 모델이 준비되면 다시 시도해 주세요."
        @unknown default:
            return "지금은 AI 한마디를 사용할 수 없어요."
        }
    }

    static func generate(for input: ReflectionCommentInput) async throws -> String {
        // 긴 복합 지시문에서 일상 회고까지 제한되던 현상을 줄이도록 목적만 짧게 전달한다.
        let session = LanguageModelSession(
            instructions: "회고에서 언급한 활동에 맞춰 다음에 해볼 작은 행동 하나를 한국어 한 문장으로 제안해 주세요."
        )
        let response = try await session.respond(
            to: input.prompt,
            options: GenerationOptions(samplingMode: .greedy, maximumResponseTokens: 256)
        )
        let comment = response.content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !comment.isEmpty else { throw GenerationFailure.emptyResponse }
        return comment
    }

    /// 모델의 응답 제한은 저장 오류와 구분해서 안내한다.
    static func failureMessage(for error: Error) -> String {
        switch error {
        case LanguageModelError.guardrailViolation, LanguageModelError.refusal:
            return "Apple Intelligence가 이번 응답을 제한했어요. 다시 시도하거나 회고 내용을 조금 더 구체적으로 적어 주세요."
        default:
            return "AI 한마디를 만들지 못했어요. 다시 시도해 주세요."
        }
    }

    private enum GenerationFailure: Error {
        case emptyResponse
    }
}
