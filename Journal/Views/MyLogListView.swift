import SwiftUI
import SwiftData

/// 마이로그 목록과 카테고리·태그 필터
struct MyLogListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \MyLog.createdAt, order: .reverse) private var myLogs: [MyLog]

    @State private var selectedCategory: String?
    @State private var selectedTags: Set<String> = []
    @State private var isPresentingNewForm = false
    @State private var editingMyLog: MyLog?

    /// 필터를 적용한 목록. 필터가 없으면 전체입니다.
    private var filteredMyLogs: [MyLog] {
        MyLog.filter(myLogs, category: selectedCategory, tags: selectedTags)
    }

    private var availableCategories: [String] {
        Set(myLogs.map(\.category)).sorted()
    }

    private var availableTags: [String] {
        Set(myLogs.flatMap(\.tags)).sorted()
    }

    var body: some View {
        NavigationStack {
            List {
                if !myLogs.isEmpty {
                    Section {
                        MyLogFilterBar(
                            selectedCategory: $selectedCategory,
                            selectedTags: $selectedTags,
                            categories: availableCategories,
                            tags: availableTags
                        )
                    }
                }

                ForEach(filteredMyLogs) { myLog in
                    Button {
                        editingMyLog = myLog
                    } label: {
                        MyLogRow(myLog: myLog)
                    }
                    .buttonStyle(.plain)
                }
                .onDelete(perform: delete)
            }
            .overlay {
                if myLogs.isEmpty {
                    ContentUnavailableView("마이로그가 없습니다", systemImage: "square.and.pencil",
                                           description: Text("오른쪽 위 + 버튼으로 첫 마이로그를 작성해 보세요."))
                } else if filteredMyLogs.isEmpty {
                    ContentUnavailableView("조건에 맞는 마이로그가 없습니다", systemImage: "line.3.horizontal.decrease.circle",
                                           description: Text("필터를 해제하면 전체 목록이 표시됩니다."))
                }
            }
            .navigationTitle("마이로그")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("새 마이로그", systemImage: "plus") { isPresentingNewForm = true }
                }
            }
            .sheet(isPresented: $isPresentingNewForm) {
                MyLogFormView()
            }
            .sheet(item: $editingMyLog) { myLog in
                MyLogFormView(myLog: myLog)
            }
        }
    }

    private func delete(at offsets: IndexSet) {
        // offsets는 필터링된 배열 기준이므로, 같은 배열에서 대상을 찾아 삭제합니다.
        let targets = offsets.map { filteredMyLogs[$0] }
        targets.forEach(modelContext.delete)
    }
}

private struct MyLogRow: View {
    let myLog: MyLog

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(myLog.title).font(.headline)
                Spacer()
                Text(myLog.category)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(.tint.opacity(0.15), in: Capsule())
            }
            if !myLog.content.isEmpty {
                Text(myLog.content)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            if !myLog.tags.isEmpty {
                Text(myLog.tags.map { "#\($0)" }.joined(separator: " "))
                    .font(.caption)
                    .foregroundStyle(.tint)
            }
            Text(myLog.createdAt, format: .dateTime.year().month().day())
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .contentShape(Rectangle())
    }
}

#Preview {
    MyLogListView()
        .modelContainer(for: MyLog.self, inMemory: true)
}
