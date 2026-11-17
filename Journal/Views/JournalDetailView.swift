import SwiftUI
import SwiftData

/// 회고 한 건의 상세 화면.
struct JournalDetailView: View {
    let journal: JournalDatabase

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(journal.title.isEmpty ? "제목 없음" : journal.title)
                    .font(.title.bold())
                    .foregroundStyle(JournalTheme.text)

                HStack {
                    Text(journal.category)
                    Text("·")
                    Text(journal.displayDateText)
                }
                .font(.subheadline)
                .foregroundStyle(JournalTheme.subText)

                if !journal.tags.isEmpty {
                    Text(journal.tags.map { "#\($0)" }.joined(separator: " "))
                        .font(.subheadline)
                        .foregroundStyle(JournalTheme.accent)
                }

                if let photoData = journal.photoData, let image = UIImage(data: photoData) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }

                if !journal.content.isEmpty {
                    Text(journal.content)
                        .font(.body)
                        .foregroundStyle(JournalTheme.text)
                }

                ForEach(Array(journal.answers.enumerated()), id: \.offset) { _, answer in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(answer.question)
                            .font(.headline)
                            .foregroundStyle(JournalTheme.accent)
                        Text(answer.text)
                            .font(.body)
                            .foregroundStyle(JournalTheme.text)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .glassCard()
            .padding()
        }
        .journalBackground()
        .navigationTitle("회고")
        .navigationBarTitleDisplayMode(.inline)
    }
}
