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
    @State private var selectedTags: Set<String> = []
    @State private var selectedJournal: JournalDatabase?
    // + 버튼을 누르면 새 회고 작성 화면으로 이동한다
    @State private var isAddingNew = false
    // 삭제를 저장하지 못했을 때 알려 주는 얼럿
    @State private var isShowingDeleteError = false
    // 알림을 누르면 해당 회고를 열기 위해 알림 담당이 전달해 주는 값
    private let router = NotificationRouter.shared
    @FocusState private var isSearchFocused: Bool

    // MARK: - 필터 후보 (목록에 있는 값에서 중복 없이 뽑는다)

    private var categories: [String] {
        journals.map(\.category).filter { !$0.isEmpty }.uniqued()
    }

    private var tags: [String] {
        journals.flatMap(\.tags).uniqued()
    }

    // MARK: - 검색 + 필터를 적용한 결과

    private var filteredJournals: [JournalDatabase] {
        let keyword = searchText.trimmingCharacters(in: .whitespaces)

        // 카테고리/태그 필터는 C의 규칙을 쓴다 (선택한 태그를 모두 가진 글만 남는다)
        let filtered = JournalDatabase.filter(journals, category: selectedCategory, tags: selectedTags)
        guard !keyword.isEmpty else { return filtered }

        return filtered.filter { journal in
            journal.title.localizedCaseInsensitiveContains(keyword)
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
                    if journals.isEmpty {
                        emptyState
                    } else {
                        cardList
                    }
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
            // 알림을 누르면 해당 회고의 상세 화면을 연다 (앱이 꺼져 있다가 켜진 경우도 포함)
            .onChange(of: router.pendingJournalID, initial: true) { openPendingJournalIfNeeded() }
            .onChange(of: journals.count) { openPendingJournalIfNeeded() }
            // 삭제로 사라진 카테고리/태그가 선택된 채로 남지 않게 해제한다
            .onChange(of: categories) {
                if let selectedCategory, !categories.contains(selectedCategory) {
                    self.selectedCategory = nil
                }
            }
            .onChange(of: tags) {
                selectedTags.formIntersection(tags)
            }
            .alert(JournalDeletion.failureMessage, isPresented: $isShowingDeleteError) {
                Button("확인", role: .cancel) {}
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

    /// 저장된 회고가 하나도 없을 때 보여 주는 안내 화면
    private var emptyState: some View {
        ContentUnavailableView {
            Label("아직 회고가 없어요", systemImage: "book.closed")
        } description: {
            Text("첫 회고를 남겨 보세요")
        } actions: {
            Button("회고 추가하기") {
                onAdd()
                isAddingNew = true
            }
            .buttonStyle(.borderedProminent)
            .tint(JournalTheme.accent)
            // 아래 전체 글자색(.foregroundStyle)이 버튼 글자까지 바꾸므로, 버튼은 흰색으로 다시 지정한다
            .foregroundStyle(.white)
        }
        .foregroundStyle(JournalTheme.text)
    }

    private var cardList: some View {
        List {
            // 필터는 목록의 첫 줄이라, 아래로 스크롤하면 위로 밀려 올라가 사라진다
            JournalFilterBar(
                selectedCategory: $selectedCategory,
                selectedTags: $selectedTags,
                categories: categories,
                tags: tags,
                horizontalInset: 20
            )
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
        let journalID = journal.id
        var isDeleted = false
        withAnimation {
            isDeleted = JournalDeletion.delete(journal, in: modelContext)
        }
        guard isDeleted else {
            // 저장하지 못해 회고를 되돌렸다. 회고가 그대로 있으니 기존 알림 예약도 건드리지 않는다
            isShowingDeleteError = true
            return
        }
        // 삭제 저장이 성공한 뒤에만 종료 알림을 정리한다
        Task { _ = await PeriodReminderScheduler.shared.reconcile(journalID: journalID, in: modelContext) }
    }
}

// MARK: - 알림으로 열기

private extension JournalListView {
    /// 알림에서 받은 회고를 상세 화면으로 연다. 이미 지워진 회고면 무시한다.
    func openPendingJournalIfNeeded() {
        guard let id = router.pendingJournalID else { return }
        if let journal = journals.first(where: { $0.id == id }) {
            isAddingNew = false
            selectedJournal = journal
            router.pendingJournalID = nil
        } else if !journals.isEmpty {
            // 목록을 다 읽었는데 없으면 삭제된 회고다
            router.pendingJournalID = nil
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
