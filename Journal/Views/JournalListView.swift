import SwiftUI
import SwiftData

/// 저널 목록과 카테고리·태그 필터
struct JournalListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \JournalDatabase.createdAt, order: .reverse) private var journals: [JournalDatabase]

    @State private var selectedCategory: String?
    @State private var selectedTags: Set<String> = []
    @State private var isPresentingNewForm = false
    @State private var isSearching = false
    @State private var searchText = ""
    @FocusState private var isSearchFieldFocused: Bool
    @State private var editingJournal: JournalDatabase?

    /// 필터를 적용한 목록. 필터가 없으면 전체입니다.
    private var filteredJournals: [JournalDatabase] {
        JournalDatabase.filter(journals, category: selectedCategory, tags: selectedTags, query: searchText)
    }

    private var availableCategories: [String] {
        Set(journals.map(\.category)).sorted()
    }

    private var availableTags: [String] {
        Set(journals.flatMap(\.tags)).sorted()
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                header

                if isSearching {
                    searchField
                }

                List {
                    if !journals.isEmpty {
                        JournalFilterBar(
                            selectedCategory: $selectedCategory,
                            selectedTags: $selectedTags,
                            categories: availableCategories,
                            tags: availableTags
                        )
                        .glassListRow()
                    }

                    ForEach(filteredJournals) { journal in
                        Button {
                            editingJournal = journal
                        } label: {
                            JournalRow(journal: journal)
                        }
                        .buttonStyle(.plain)
                        .glassListRow()
                    }
                    .onDelete(perform: delete)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .overlay {
                    if journals.isEmpty {
                        ContentUnavailableView("저널이 없습니다", systemImage: "square.and.pencil",
                                               description: Text("오른쪽 위 + 버튼으로 첫 저널을 작성해 보세요."))
                    } else if filteredJournals.isEmpty {
                        ContentUnavailableView("조건에 맞는 저널이 없습니다", systemImage: "line.3.horizontal.decrease.circle",
                                               description: Text("검색어나 필터를 해제하면 전체 목록이 표시됩니다."))
                    }
                }
            }
            .journalBackground()
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $isPresentingNewForm) {
                JournalFormView()
            }
            .sheet(item: $editingJournal) { journal in
                JournalFormView(journal: journal)
            }
        }
    }

    /// 큰 제목과 새 저널 버튼
    private var header: some View {
        HStack {
            Text("저널")
                .font(.system(size: 30, weight: .heavy, design: .rounded))
                .foregroundStyle(JournalTheme.text)
            Spacer()
            Button {
                toggleSearch()
            } label: {
                Image(systemName: isSearching ? "xmark" : "magnifyingglass")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(JournalTheme.accent)
                    .frame(width: 36, height: 36)
                    .background(JournalTheme.glassFill, in: Circle())
                    .overlay { Circle().strokeBorder(JournalTheme.glassBorder, lineWidth: 1) }
            }
            .accessibilityLabel(isSearching ? "검색 닫기" : "검색")
            Button {
                isPresentingNewForm = true
            } label: {
                Image(systemName: "plus")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(JournalTheme.accent, in: Circle())
            }
            .accessibilityLabel("새 저널")
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 4)
    }

    /// 검색어를 입력하는 유리 질감의 입력창
    private var searchField: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(JournalTheme.subText)
            TextField("제목, 본문, 카테고리, 태그 검색", text: $searchText)
                .focused($isSearchFieldFocused)
                .submitLabel(.search)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(JournalTheme.subText)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("검색어 지우기")
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .glassCard(cornerRadius: 16)
        .padding(.horizontal, 20)
        .padding(.bottom, 4)
        .transition(.move(edge: .top).combined(with: .opacity))
    }

    /// 검색창을 열고 닫습니다. 닫으면 검색어도 지워 전체 목록으로 돌아갑니다.
    private func toggleSearch() {
        withAnimation(.snappy) {
            isSearching.toggle()
            if !isSearching { searchText = "" }
        }
        isSearchFieldFocused = isSearching
    }

    private func delete(at offsets: IndexSet) {
        // offsets는 필터링된 배열 기준이므로, 같은 배열에서 대상을 찾아 삭제합니다.
        let targets = offsets.map { filteredJournals[$0] }
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

private struct JournalRow: View {
    let journal: JournalDatabase

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(journal.title)
                    .font(.headline)
                    .foregroundStyle(JournalTheme.text)
                Spacer()
                Text(journal.category)
                    .font(.caption)
                    .foregroundStyle(JournalTheme.badgeText)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(JournalTheme.accent.opacity(0.15), in: Capsule())
            }
            if !journal.content.isEmpty {
                Text(journal.content)
                    .font(.subheadline)
                    .foregroundStyle(JournalTheme.subText)
                    .lineLimit(2)
            }
            if !journal.tags.isEmpty {
                Text(journal.tags.map { "#\($0)" }.joined(separator: " "))
                    .font(.caption)
                    .foregroundStyle(JournalTheme.accent)
            }
            Text(journal.createdAt, format: .dateTime.year().month().day())
                .font(.caption2)
                .foregroundStyle(JournalTheme.subText)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard()
        .contentShape(Rectangle())
    }
}

#Preview {
    JournalListView()
        .modelContainer(for: JournalDatabase.self, inMemory: true)
}
