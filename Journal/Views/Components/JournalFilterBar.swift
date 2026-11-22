import SwiftUI

/// 필터 UI. 카테고리 하나와 태그 여러 개를 골라 목록을 좁힙니다.
/// 아무것도 고르지 않으면 필터가 꺼진 상태이고, "필터 해제"를 누르면 모두 초기화됩니다.
struct JournalFilterBar: View {
    @Binding var selectedCategory: String?
    @Binding var selectedTags: Set<String>
    @Binding var showsUntaggedOnly: Bool

    let categories: [String]
    let tags: [String]
    /// 좌우 여백. 칩 줄은 화면 끝까지 스크롤되고, 첫 칩과 마지막 칩만 이 여백만큼 안쪽에서 시작/끝납니다.
    var horizontalInset: CGFloat = 0

    private var isFiltering: Bool {
        selectedCategory != nil || !selectedTags.isEmpty || showsUntaggedOnly
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            if !categories.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        JournalChip(title: "전체", isSelected: selectedCategory == nil) {
                            selectedCategory = nil
                        }
                        ForEach(categories, id: \.self) { name in
                            JournalChip(title: JournalCategory.title(for: name), isSelected: selectedCategory == name) {
                                // 선택된 카테고리를 다시 누르면 해제합니다.
                                selectedCategory = (selectedCategory == name) ? nil : name
                            }
                        }
                    }
                    .padding(.horizontal, horizontalInset)
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    // '태그 없음'은 실제 태그를 붙이는 것이 아니라 조회 조건입니다.
                    JournalChip(title: "태그 없음", isSelected: showsUntaggedOnly) {
                        showsUntaggedOnly.toggle()
                        if showsUntaggedOnly { selectedTags.removeAll() }
                    }
                    ForEach(tags, id: \.self) { tag in
                        JournalChip(title: "#\(tag)", isSelected: selectedTags.contains(tag)) {
                            showsUntaggedOnly = false
                            if selectedTags.contains(tag) {
                                selectedTags.remove(tag)
                            } else {
                                selectedTags.insert(tag)
                            }
                        }
                    }
                }
                .padding(.horizontal, horizontalInset)
            }

            if isFiltering {
                Button {
                    selectedCategory = nil
                    selectedTags.removeAll()
                    showsUntaggedOnly = false
                } label: {
                    Label("필터 해제", systemImage: "xmark.circle")
                        .font(.footnote)
                        .foregroundStyle(JournalTheme.subText)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, horizontalInset)
            }
        }
    }
}

#Preview {
    @Previewable @State var category: String? = "업무"
    @Previewable @State var tags: Set<String> = ["swift"]
    @Previewable @State var showsUntaggedOnly = false

    JournalFilterBar(
        selectedCategory: $category,
        selectedTags: $tags,
        showsUntaggedOnly: $showsUntaggedOnly,
        categories: ["공부", "업무", "운동"],
        tags: ["swift", "독서", "러닝"],
        horizontalInset: 20
    )
    .padding(.vertical)
    .background(JournalTheme.background)
}
