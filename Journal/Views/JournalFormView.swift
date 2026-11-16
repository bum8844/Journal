import SwiftUI
import SwiftData

/// 저널 작성·편집 폼. `journal`이 nil이면 새로 만들고, 있으면 편집합니다.
struct JournalFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    /// 태그 추천에 쓰기 위해 기존 저널을 조회합니다.
    @Query private var allJournals: [JournalDatabase]

    let journal: JournalDatabase?

    @State private var title: String
    @State private var content: String
    @State private var category: String
    @State private var tags: [String]
    @State private var tagInput = ""

    init(journal: JournalDatabase? = nil) {
        self.journal = journal
        _title = State(initialValue: journal?.title ?? "")
        _content = State(initialValue: journal?.content ?? "")
        _category = State(initialValue: journal?.category ?? "")
        _tags = State(initialValue: journal?.tags ?? [])
    }

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && JournalDatabase.normalizedCategory(category) != nil
    }

    /// 이미 만든 카테고리 목록. 입력창에 추천으로 보여줍니다.
    private var existingCategories: [String] {
        Set(allJournals.map(\.category)).sorted()
    }

    /// 이미 쓴 태그 목록. 입력창에 추천으로 보여줍니다.
    private var existingTags: [String] {
        Set(allJournals.flatMap(\.tags)).sorted()
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("제목") {
                    TextField("제목", text: $title)
                }
                .listRowBackground(JournalTheme.glassFill)

                Section("본문") {
                    TextEditor(text: $content)
                        .scrollContentBackground(.hidden)
                        .frame(minHeight: 160)
                }
                .listRowBackground(JournalTheme.glassFill)

                JournalClassificationPicker(
                    category: $category,
                    tags: $tags,
                    tagInput: $tagInput,
                    categorySuggestions: existingCategories,
                    tagSuggestions: existingTags
                )
            }
            .scrollContentBackground(.hidden)
            .journalBackground()
            .navigationTitle(journal == nil ? "새 저널" : "저널 편집")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장", action: save)
                        .disabled(!canSave)
                }
            }
        }
    }

    private func save() {
        // 입력창에 남은 태그도 저장에 포함합니다.
        tags = JournalDatabase.tags(tags, adding: tagInput)
        tagInput = ""

        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let trimmedCategory = JournalDatabase.normalizedCategory(category) else { return }
        if let journal {
            journal.title = trimmedTitle
            journal.content = content
            journal.category = trimmedCategory
            journal.tags = tags
        } else {
            modelContext.insert(
                JournalDatabase(title: trimmedTitle, content: content, category: trimmedCategory, tags: tags)
            )
        }
        dismiss()
    }
}

#Preview {
    JournalFormView()
        .modelContainer(for: JournalDatabase.self, inMemory: true)
}
