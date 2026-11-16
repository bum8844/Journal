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
            VStack(spacing: 0) {
                header

                List {
                    if !myLogs.isEmpty {
                        MyLogFilterBar(
                            selectedCategory: $selectedCategory,
                            selectedTags: $selectedTags,
                            categories: availableCategories,
                            tags: availableTags
                        )
                        .glassListRow()
                    }

                    ForEach(filteredMyLogs) { myLog in
                        Button {
                            editingMyLog = myLog
                        } label: {
                            MyLogRow(myLog: myLog)
                        }
                        .buttonStyle(.plain)
                        .glassListRow()
                    }
                    .onDelete(perform: delete)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .overlay {
                    if myLogs.isEmpty {
                        ContentUnavailableView("마이로그가 없습니다", systemImage: "square.and.pencil",
                                               description: Text("오른쪽 위 + 버튼으로 첫 마이로그를 작성해 보세요."))
                    } else if filteredMyLogs.isEmpty {
                        ContentUnavailableView("조건에 맞는 마이로그가 없습니다", systemImage: "line.3.horizontal.decrease.circle",
                                               description: Text("필터를 해제하면 전체 목록이 표시됩니다."))
                    }
                }
            }
            .myLogBackground()
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $isPresentingNewForm) {
                MyLogFormView()
            }
            .sheet(item: $editingMyLog) { myLog in
                MyLogFormView(myLog: myLog)
            }
        }
    }

    /// 큰 제목과 새 마이로그 버튼
    private var header: some View {
        HStack {
            Text("마이로그")
                .font(.system(size: 30, weight: .heavy, design: .rounded))
                .foregroundStyle(MyLogTheme.text)
            Spacer()
            Button {
                isPresentingNewForm = true
            } label: {
                Image(systemName: "plus")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(MyLogTheme.accent, in: Circle())
            }
            .accessibilityLabel("새 마이로그")
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 4)
    }

    private func delete(at offsets: IndexSet) {
        // offsets는 필터링된 배열 기준이므로, 같은 배열에서 대상을 찾아 삭제합니다.
        let targets = offsets.map { filteredMyLogs[$0] }
        targets.forEach(modelContext.delete)
    }
}

/// 목록 행에서 배경과 구분선을 없애 유리 카드가 보이게 합니다.
private extension View {
    func glassListRow() -> some View {
        listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 6, leading: 18, bottom: 6, trailing: 18))
    }
}

private struct MyLogRow: View {
    let myLog: MyLog

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(myLog.title)
                    .font(.headline)
                    .foregroundStyle(MyLogTheme.text)
                Spacer()
                Text(myLog.category)
                    .font(.caption)
                    .foregroundStyle(MyLogTheme.badgeText)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(MyLogTheme.accent.opacity(0.15), in: Capsule())
            }
            if !myLog.content.isEmpty {
                Text(myLog.content)
                    .font(.subheadline)
                    .foregroundStyle(MyLogTheme.subText)
                    .lineLimit(2)
            }
            if !myLog.tags.isEmpty {
                Text(myLog.tags.map { "#\($0)" }.joined(separator: " "))
                    .font(.caption)
                    .foregroundStyle(MyLogTheme.accent)
            }
            Text(myLog.createdAt, format: .dateTime.year().month().day())
                .font(.caption2)
                .foregroundStyle(MyLogTheme.subText)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard()
        .contentShape(Rectangle())
    }
}

#Preview {
    MyLogListView()
        .modelContainer(for: MyLog.self, inMemory: true)
}
