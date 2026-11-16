//
//  JournalListView.swift
//  Journal
//
//  마이로그 리스트 화면 (검색 + 카테고리/태그 필터 + 카드 목록)
//  SwiftData에서 회고 목록을 읽고, 스와이프 삭제도 저장소에서 지운다.
//

import SwiftUI
import SwiftData

struct JournalListView: View {
    // 저장된 회고를 최신순으로 자동으로 읽어 온다 (저장/삭제되면 화면도 자동 갱신)
    @Query(sort: \JournalDatabase.createdAt, order: .reverse)
    private var journals: [JournalDatabase]
    @Environment(\.modelContext) private var modelContext

    var onAdd: () -> Void = {}

    @State private var searchText = ""
    @State private var selectedCategory: String?
    @State private var selectedTag: String?
    @State private var selectedJournal: JournalDatabase?
    // + 버튼을 누르면 새 회고 작성 화면으로 이동한다
    @State private var isAddingNew = false
    @FocusState private var isSearchFocused: Bool

    // MARK: - 필터 후보 (목록에 있는 값에서 중복 없이 뽑는다)

    private var categories: [String] {
        journals.map(\.category).uniqued()
    }

    private var tags: [String] {
        journals.flatMap(\.tags).uniqued()
    }

    // MARK: - 검색 + 필터를 적용한 결과

    private var filteredJournals: [JournalDatabase] {
        let keyword = searchText.trimmingCharacters(in: .whitespaces)

        return journals.filter { journal in
            if let selectedCategory, journal.category != selectedCategory { return false }
            if let selectedTag, !journal.tags.contains(selectedTag) { return false }
            guard !keyword.isEmpty else { return true }

            return journal.title.localizedCaseInsensitiveContains(keyword)
                || journal.content.localizedCaseInsensitiveContains(keyword)
                || journal.category.localizedCaseInsensitiveContains(keyword)
                || journal.tags.contains { $0.localizedCaseInsensitiveContains(keyword) }
        }
    }

    // MARK: - 화면

    var body: some View {
        NavigationStack {
            ZStack {
                JournalTheme.background.ignoresSafeArea()

                VStack(alignment: .leading, spacing: 14) {
                    header
                    cardList
                }
                .padding(.top, 8)
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(item: $selectedJournal) { journal in
                JournalDetailView(journal: journal)
            }
            .navigationDestination(isPresented: $isAddingNew) {
                JournalEditorView()
            }
            // 삭제로 사라진 카테고리/태그가 선택된 채로 남지 않게 해제한다
            .onChange(of: categories) {
                if let selectedCategory, !categories.contains(selectedCategory) {
                    self.selectedCategory = nil
                }
            }
            .onChange(of: tags) {
                if let selectedTag, !tags.contains(selectedTag) {
                    self.selectedTag = nil
                }
            }
        }
    }

    private var header: some View {
        HStack {
            Text("마이로그")
                .font(.largeTitle.bold())
                .foregroundStyle(JournalTheme.text)

            Spacer()

            // 검색창을 눌렀을 때만 나타난다. 검색어를 지우고 키보드를 닫는다
            if isSearchFocused {
                Button {
                    searchText = ""
                    isSearchFocused = false
                } label: {
                    Image(systemName: "xmark")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(JournalTheme.accent)
                        .frame(width: 52, height: 52)
                        .glassCard(cornerRadius: 26)
                }
                .accessibilityLabel("검색 닫기")
                .transition(.scale.combined(with: .opacity))
            }

            Button {
                onAdd()
                isAddingNew = true
            } label: {
                Image(systemName: "plus")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 52, height: 52)
                    .background(Circle().fill(JournalTheme.accent))
            }
            .accessibilityLabel("새 회고 작성")
        }
        .padding(.horizontal, 20)
        .animation(.easeInOut(duration: 0.2), value: isSearchFocused)
    }

    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                FilterChipView(title: "전체", isSelected: selectedCategory == nil) {
                    selectedCategory = nil
                }
                ForEach(categories, id: \.self) { category in
                    FilterChipView(title: category, isSelected: selectedCategory == category) {
                        selectedCategory = category
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }

    private var tagChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(tags, id: \.self) { tag in
                    FilterChipView(title: "#\(tag)", isSelected: selectedTag == tag) {
                        // 같은 태그를 다시 누르면 해제
                        selectedTag = (selectedTag == tag) ? nil : tag
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }

    private var cardList: some View {
        List {
            // 칩은 목록의 첫 줄이라, 아래로 스크롤하면 위로 밀려 올라가 사라진다
            VStack(alignment: .leading, spacing: 14) {
                categoryChips
                tagChips
            }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 7, trailing: 0))

            ForEach(filteredJournals) { journal in
                Button {
                    selectedJournal = journal
                } label: {
                    JournalCardView(journal: journal)
                }
                .buttonStyle(.plain)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 7, leading: 20, bottom: 7, trailing: 20))
                // 오른쪽에서 왼쪽으로 밀면 삭제 버튼이 나타난다 (끝까지 밀면 바로 삭제)
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        delete(journal)
                    } label: {
                        Label("삭제", systemImage: "trash")
                    }
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .scrollDismissesKeyboard(.interactively)
        // 검색창은 위에 고정된다. 스크롤하면 목록이 검색창 뒤로 지나가며 비쳐 보인다
        .safeAreaInset(edge: .top, spacing: 0) {
            JournalSearchBar(text: $searchText, isFocused: $isSearchFocused)
                .padding(.horizontal, 20)
                .padding(.vertical, 6)
        }
    }
}

// MARK: - 삭제

private extension JournalListView {
    /// 저장소에서 회고를 지우고 바로 저장한다 (앱을 다시 켜도 삭제된 상태 유지)
    func delete(_ journal: JournalDatabase) {
        withAnimation {
            modelContext.delete(journal)
            try? modelContext.save()
        }
    }
}

// MARK: - 중복 제거 (처음 나온 순서는 유지)

private extension Sequence where Element: Hashable {
    func uniqued() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}

#Preview("리스트") {
    // 메모리에만 잠깐 저장되는 컨테이너라, 프리뷰를 새로고침하면 샘플이 다시 채워진다
    let container = try! ModelContainer(
        for: JournalDatabase.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    JournalDatabase.samples.forEach { container.mainContext.insert($0) }
    return JournalListView().modelContainer(container)
}
