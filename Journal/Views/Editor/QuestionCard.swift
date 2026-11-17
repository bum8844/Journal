import SwiftUI

/// 오늘의 경험·내일을 위한 정리의 질문 목록을 한 카드에 담아 질문마다 입력칸을 보여 줍니다.
/// 답변은 질문 순서대로 answers 배열에 들어갑니다.
struct QuestionCard: View {
    let questions: [JournalQuestion]
    @Binding var answers: [String]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(questions.enumerated()), id: \.element.id) { index, question in
                if index > 0 {
                    Divider()
                        .overlay(JournalTheme.glassBorder)
                        .padding(.leading, 40)
                }
                QuestionRow(number: index + 1, question: question, answer: answerBinding(at: index))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
        .fieldBackground()
    }

    // 답변 배열이 질문 수보다 짧아도 안전하게 읽고 쓰도록 감쌉니다.
    private func answerBinding(at index: Int) -> Binding<String> {
        Binding(
            get: { index < answers.count ? answers[index] : "" },
            set: { newValue in
                if index < answers.count { answers[index] = newValue }
            }
        )
    }
}

/// 번호 배지 + 굵은 질문 제목 + 답변 입력칸(안내 문구가 흐리게 들어 있음) 한 줄
private struct QuestionRow: View {
    let number: Int
    let question: JournalQuestion
    @Binding var answer: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(String(format: "%02d", number))
                .font(.caption.weight(.bold))
                .monospacedDigit()
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background(JournalTheme.accent, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(question.title)
                    .font(.headline)

                TextField(
                    question.title,
                    text: $answer,
                    prompt: Text(question.placeholder).foregroundStyle(JournalTheme.subText),
                    axis: .vertical
                )
                .font(.subheadline)
                .lineLimit(1...6)
            }
        }
        .padding(.vertical, 12)
    }
}

#Preview {
    @Previewable @State var answers = ["계산기 앱을 완성한 순간", "", "", ""]

    QuestionCard(questions: ReflectionFormat.fourL.questions, answers: $answers)
        .padding(20)
        .journalBackground()
}
