import SwiftUI

/// 자유 형식에서 글감이 되는 "오늘의 질문"을 보여 주는 카드.
/// 오른쪽 버튼을 누르면 다른 질문으로 바뀝니다. 질문은 안내용이라 저장되지 않습니다.
struct TodayQuestionCard: View {
    private static let questions = [
        "오늘 나를 웃게 한 건 뭐였나요?",
        "오늘 가장 고마웠던 순간은 언제였나요?",
        "오늘 나에게 해주고 싶은 말은 무엇인가요?",
        "오늘 새롭게 알게 된 건 뭐였나요?",
        "오늘 가장 기억에 남는 장면은 무엇인가요?",
        "오늘 하루를 한 단어로 말한다면?",
        "오늘 잘한 일 하나를 꼽는다면 무엇인가요?"
    ]

    @State private var question = TodayQuestionCard.questions.randomElement() ?? ""

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Label("오늘의 질문", systemImage: "lightbulb")
                    .font(.caption)
                    .foregroundStyle(JournalTheme.subText)

                Text(question)
                    .font(.body.weight(.medium))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 8)

            Button(action: refresh) {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(JournalTheme.accent)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("다른 질문 보기")
        }
        .padding(.leading, 16)
        .padding(.trailing, 4)
        .padding(.vertical, 10)
        .fieldBackground()
    }

    /// 지금 보이는 질문과 다른 질문을 고릅니다.
    private func refresh() {
        let others = Self.questions.filter { $0 != question }
        question = others.randomElement() ?? question
    }
}

#Preview {
    TodayQuestionCard()
        .padding(20)
        .journalBackground()
}
