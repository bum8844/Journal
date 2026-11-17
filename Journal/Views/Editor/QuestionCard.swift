import SwiftUI

/// KPT·4L의 질문 목록을 한 카드에 담아 질문마다 입력칸을 보여 줍니다.
/// 답변은 질문 순서대로 answers 배열에 들어갑니다.
struct QuestionCard: View {
    let questions: [JournalQuestion]
    @Binding var answers: [String]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(questions.enumerated()), id: \.element.id) { index, question in
                if index > 0 {
                    Divider().overlay(JournalTheme.glassBorder)
                }
                QuestionRow(question: question, answer: answerBinding(at: index))
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

/// 아이콘 + "영어 · 한글" 질문명 + 답변 입력칸 한 줄
private struct QuestionRow: View {
    let question: JournalQuestion
    @Binding var answer: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(question.initial)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 34, height: 34)
                .background(JournalTheme.accent, in: RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Text(question.english).fontWeight(.semibold)
                    Text("· \(question.korean)").foregroundStyle(JournalTheme.subText)
                }

                TextField(question.placeholder, text: $answer, axis: .vertical)
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
