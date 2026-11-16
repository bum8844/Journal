import SwiftUI
import SwiftData

/// 마이로그 작성·편집 폼. `myLog`이 nil이면 새로 만들고, 있으면 편집합니다.
struct MyLogFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    /// 태그 추천에 쓰기 위해 기존 마이로그를 조회합니다.
    @Query private var allMyLogs: [JournalDatabase]

    let myLog: JournalDatabase?

    @State private var title: String
    @State private var content: String
    @State private var category: String
    @State private var tags: [String]
    @State private var tagInput = ""

    init(myLog: JournalDatabase? = nil) {
        self.myLog = myLog
        _title = State(initialValue: myLog?.title ?? "")
        _content = State(initialValue: myLog?.content ?? "")
        _category = State(initialValue: myLog?.category ?? "")
        _tags = State(initialValue: myLog?.tags ?? [])
    }

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && JournalDatabase.normalizedCategory(category) != nil
    }

    /// 이미 만든 카테고리 목록. 입력창에 추천으로 보여줍니다.
    private var existingCategories: [String] {
        Set(allMyLogs.map(\.category)).sorted()
    }

    /// 이미 쓴 태그 목록. 입력창에 추천으로 보여줍니다.
    private var existingTags: [String] {
        Set(allMyLogs.flatMap(\.tags)).sorted()
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("제목") {
                    TextField("제목", text: $title)
                }
                .listRowBackground(MyLogTheme.glassFill)

                Section("본문") {
                    TextEditor(text: $content)
                        .scrollContentBackground(.hidden)
                        .frame(minHeight: 160)
                }
                .listRowBackground(MyLogTheme.glassFill)

                MyLogClassificationPicker(
                    category: $category,
                    tags: $tags,
                    tagInput: $tagInput,
                    categorySuggestions: existingCategories,
                    tagSuggestions: existingTags
                )
            }
            .scrollContentBackground(.hidden)
            .myLogBackground()
            .navigationTitle(myLog == nil ? "새 마이로그" : "마이로그 편집")
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
        if let myLog {
            myLog.title = trimmedTitle
            myLog.content = content
            myLog.category = trimmedCategory
            myLog.tags = tags
        } else {
            modelContext.insert(
                JournalDatabase(title: trimmedTitle, content: content, category: trimmedCategory, tags: tags)
            )
        }
        dismiss()
    }
}

#Preview {
    MyLogFormView()
        .modelContainer(for: JournalDatabase.self, inMemory: true)
}
