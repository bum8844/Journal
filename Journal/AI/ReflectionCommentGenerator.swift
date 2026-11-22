import Foundation
import FoundationModels

/// 기기 안의 Apple Intelligence 모델(Foundation Models)로 회고 한마디를 만든다. 글이 기기 밖으로 나가지 않는다.
enum ReflectionCommentGenerator {
    /// 모델을 쓸 수 없는 이유를 안내 문구로 돌려준다. 쓸 수 있으면 nil.
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

    /// 회고 내용으로 다음에 시도할 행동 한 가지를 한국어 1~2문장으로 만든다.
    static func generate(for input: ReflectionCommentInput) async throws -> String {
        try await generate(
            for: input,
            request: { try await requestResponse(for: input) },
            waitForPreparation: { try await Task.sleep(for: .seconds(2)) }
        )
    }

    /// 준비 오류에서만 한 번 더 요청합니다.
    /// 테스트에서는 실제 모델 요청과 대기 대신 확인용 함수를 전달해 재시도·취소를 검증합니다.
    static func generate(
        for input: ReflectionCommentInput,
        request: () async throws -> String,
        waitForPreparation: () async throws -> Void
    ) async throws -> String {
        guard input.canGenerate else { throw GenerationFailure.insufficientContent }
        try Task.checkCancellation()
        let response: String
        do {
            response = try await request()
        } catch {
            guard isModelPreparationError(error) else { throw error }
            try Task.checkCancellation()
            try await waitForPreparation()
            try Task.checkCancellation()
            // 새 요청도 실패하면 해당 오류를 그대로 안내하고 끝냅니다. 반복 재시도하지 않습니다.
            response = try await request()
        }
        try Task.checkCancellation()
        let comment = suggestion(from: response)
        guard !comment.isEmpty else { throw GenerationFailure.noActionableSuggestion }
        return comment
    }

    private static func requestResponse(for input: ReflectionCommentInput) async throws -> String {
        if case .unavailable(.modelNotReady) = SystemLanguageModel.default.availability {
            throw GenerationFailure.modelPreparing
        }
        // 회고 속 '나'를 AI 자신으로 해석하지 않도록 작성자와 응답자의 역할을 구분합니다.
        let session = LanguageModelSession(
            instructions: """
            사용자가 쓴 회고를 읽고, 그 사람이 다음에 직접 해 볼 작은 행동 하나를 한국어 존댓말 한 문장으로 제안하세요.
            무엇을 어떻게 할지 구체적으로 쓰고 '해 보세요' 또는 '어떨까요?'로 권하세요.
            인사, 평가, 회고 요약, '행동을 추천합니다' 같은 소개 문장은 쓰지 마세요.
            회고에 없는 사실을 지어내지 말고, 정보가 적으면 관련된 작은 준비 행동을 제안하세요.
            """
        )
        let response = try await session.respond(
            to: input.prompt,
            // 특정 문장의 실패가 반복되던 greedy 고정 대신 모델의 기본 생성 방식을 사용합니다.
            // Apple의 안전 필터는 그대로 적용되며, 제한된 응답을 재시도해서 우회하지 않습니다.
            options: GenerationOptions(maximumResponseTokens: 256)
        )
        return response.content
    }

    /// 모델이 회고를 길게 되풀이했을 때, 실제로 권유한 문장만 한마디로 보여 줍니다.
    /// 새 문장을 꾸며 넣거나 '하겠습니다'를 '해 보세요'로 임의로 바꾸지 않습니다.
    static func suggestion(from response: String) -> String {
        var sentences: [String] = []
        response.enumerateSubstrings(in: response.startIndex..<response.endIndex, options: .bySentences) { text, _, _, _ in
            if let text {
                let sentence = text.trimmingCharacters(in: .whitespacesAndNewlines)
                if !sentence.isEmpty { sentences.append(sentence) }
            }
        }
        return sentences.first { sentence in
            // '추천'만 들어 있는 소개·요약을 실제 행동 제안으로 받아들이지 않습니다.
            // 모델의 모든 의미를 판정하는 검사는 아니며, 확인된 빈 소개 문장을 걸러 냅니다.
            let isInvitation = sentence.contains("보세요") || sentence.contains("어떨까요")
            let isIntroduction = ["추천해 드", "추천해드", "제안해 드", "제안해드", "추천합니다", "제안합니다"]
                .contains { sentence.contains($0) }
            return isInvitation && !isIntroduction && !sentence.contains("겠습니다")
        } ?? ""
    }

    /// 모델의 응답 제한은 저장 오류와 구분해서 안내한다.
    static func failureMessage(for error: Error) -> String {
        if isModelPreparationError(error) {
            return "AI 모델을 아직 준비하지 못했어요. 잠시 후 다시 시도해 주세요. 회고는 그대로 저장할 수 있어요."
        }
        switch error {
        case GenerationFailure.insufficientContent:
            return "단어나 문장으로 회고 내용을 조금 더 적어 주세요."
        case GenerationFailure.noActionableSuggestion:
            return "구체적인 행동 제안을 만들지 못했어요. 다시 생성해 주세요. 회고는 그대로 저장할 수 있어요."
        case LanguageModelError.guardrailViolation, LanguageModelError.refusal:
            return "Apple Intelligence의 응답 제한으로 생성하지 못했어요. 회고는 AI 한마디 없이도 저장할 수 있어요."
        default:
            return "AI 한마디를 만들지 못했어요. 다시 시도해 주세요."
        }
    }

    /// 응답 제한과 내부 모델 준비 실패를 구분합니다. 오류 문구의 단어 검색으로 판정하지 않습니다.
    private static func isModelPreparationError(_ error: Error) -> Bool {
        // 안전 필터가 실제로 응답을 제한한 경우에는 대기나 자동 재시도를 하지 않습니다.
        switch error {
        case LanguageModelError.guardrailViolation, LanguageModelError.refusal: return false
        case GenerationFailure.modelPreparing: return true
        default: break
        }

        // 부팅 직후 관찰한 자산 오류가 중첩 NSError 안에 들어 있었습니다.
        // 모든 필터 오류를 준비 오류로 처리하지 않고, 확인한 도메인·코드만 분류합니다.
        var pending = [error as NSError]
        var visited = Set<ObjectIdentifier>()
        while let current = pending.popLast() {
            guard visited.insert(ObjectIdentifier(current)).inserted else { continue }
            if current.domain == "OnDeviceInferenceAssetRepository", current.code == 2 { return true }
            if let underlying = current.userInfo[NSUnderlyingErrorKey] as? NSError {
                pending.append(underlying)
            }
            if let underlying = current.userInfo["NSMultipleUnderlyingErrorsKey"] as? [NSError] {
                pending.append(contentsOf: underlying)
            }
        }
        return false
    }

    private enum GenerationFailure: Error {
        case noActionableSuggestion
        case insufficientContent
        case modelPreparing
    }
}
