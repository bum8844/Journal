//
//  JournalListView.swift
//  Journal
//
//  마이로그 리스트 화면 (검색 + 카테고리/태그 필터 + 카드 목록)
//  데이터베이스 연결 전이므로 journals를 바깥에서 받는다.
//

import SwiftUI

struct JournalListView: View {
    let journals: [JournalDatabase]
    var onAdd: () -> Void = {}

    @State private var searchText = ""
    @State private var selectedCategory: String?
    @State private var selectedTag: String?
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
        ZStack {
            JournalTheme.background.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 14) {
                header
                JournalSearchBar(text: $searchText, isFocused: $isSearchFocused)
                    .padding(.horizontal, 20)
                categoryChips
                tagChips
                cardList
            }
            .padding(.top, 8)
        }
    }

    private var header: some View {
        HStack {
            Text("마이로그")
                .font(.largeTitle.bold())
                .foregroundStyle(JournalTheme.titleText)

            Spacer()

            // 검색어를 지우고 키보드를 닫는다
            Button {
                searchText = ""
                isSearchFocused = false
            } label: {
                Image(systemName: "xmark")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(JournalTheme.accent)
                    .frame(width: 52, height: 52)
                    .background(Circle().fill(Color.white.opacity(0.55)))
                    .overlay(Circle().stroke(Color.white.opacity(0.7), lineWidth: 1))
            }
            .accessibilityLabel("검색 닫기")

            Button(action: onAdd) {
                Image(systemName: "plus")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 52, height: 52)
                    .background(Circle().fill(JournalTheme.accent))
            }
            .accessibilityLabel("새 회고 작성")
        }
        .padding(.horizontal, 20)
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
        ScrollView {
            LazyVStack(spacing: 14) {
                ForEach(filteredJournals) { journal in
                    JournalCardView(journal: journal)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 4)
            .padding(.bottom, 24)
        }
        .scrollDismissesKeyboard(.interactively)
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
    JournalListView(journals: JournalDatabase.samples)
}
