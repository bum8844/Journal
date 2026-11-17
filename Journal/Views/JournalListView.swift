import SwiftUI
import SwiftData

/// 저장된 회고 목록. 항목을 누르면 상세로 이동하고, 왼쪽으로 스와이프하면 삭제합니다.
struct JournalListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \JournalDatabase.createdAt, order: .reverse)
    private var journals: [JournalDatabase]

    @State private var deleteErrorMessage: String?

    var body: some View {
        NavigationStack {
            Group {
                if journals.isEmpty {
                    ContentUnavailableView("저장된 회고가 없어요", systemImage: "book.closed")
                } else {
                    List {
                        ForEach(journals) { journal in
                            NavigationLink(value: journal) {
                                JournalRow(journal: journal)
                            }
                            .listRowBackground(Color.clear)
                        }
                        .onDelete(perform: delete)
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .journalBackground()
            .navigationTitle("회고")
            .navigationDestination(for: JournalDatabase.self) { journal in
                JournalDetailView(journal: journal)
            }
            .alert("삭제하지 못했어요", isPresented: Binding(
                get: { deleteErrorMessage != nil },
                set: { if !$0 { deleteErrorMessage = nil } }
            )) {
                Button("확인", role: .cancel) {}
            } message: {
                Text(deleteErrorMessage ?? "")
            }
        }
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(journals[index])
        }
        do {
            // 앱을 바로 종료해도 삭제가 남도록 즉시 저장합니다.
            try modelContext.save()
        } catch {
            modelContext.rollback()
            deleteErrorMessage = error.localizedDescription
        }
    }
}

private struct JournalRow: View {
    let journal: JournalDatabase

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(journal.title.isEmpty ? "제목 없음" : journal.title)
                .font(.headline)
                .foregroundStyle(JournalTheme.text)
            Text(journal.content)
                .font(.subheadline)
                .foregroundStyle(JournalTheme.subText)
                .lineLimit(2)
            HStack {
                Text(journal.category)
                Spacer()
                Text(journal.createdAt, format: .dateTime.year().month().day())
            }
            .font(.caption)
            .foregroundStyle(JournalTheme.subText)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    let container = try! ModelContainer(
        for: JournalDatabase.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    container.mainContext.insert(
        JournalDatabase(title: "첫 회고", content: "이번 주에 배운 점을 정리했다.", category: "학습", tags: ["swift"])
    )
    return JournalListView().modelContainer(container)
}
