import SwiftUI

/// 필터 UI. 카테고리 하나와 태그 여러 개를 골라 목록을 좁힙니다.
/// 아무것도 고르지 않으면 필터가 꺼진 상태이고, "필터 해제"를 누르면 모두 초기화됩니다.
struct JournalFilterBar: View {
    @Binding var selectedCategory: String?
    @Binding var selectedTags: Set<String>

    let categories: [String]
    let tags: [String]

    private var isFiltering: Bool {
        selectedCategory != nil || !selectedTags.isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !categories.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        JournalChip(title: "전체", isSelected: selectedCategory == nil) {
                            selectedCategory = nil
                        }
                        ForEach(categories, id: \.self) { name in
                            JournalChip(title: name, isSelected: selectedCategory == name) {
                                // 선택된 카테고리를 다시 누르면 해제합니다.
                                selectedCategory = (selectedCategory == name) ? nil : name
                            }
                        }
                    }
                }
            }

            if !tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(tags, id: \.self) { tag in
                            JournalChip(title: "#\(tag)", isSelected: selectedTags.contains(tag)) {
                                if selectedTags.contains(tag) {
                                    selectedTags.remove(tag)
                                } else {
                                    selectedTags.insert(tag)
                                }
                            }
                        }
                    }
                }
            }

            if isFiltering {
                Button {
                    selectedCategory = nil
                    selectedTags.removeAll()
                } label: {
                    Label("필터 해제", systemImage: "xmark.circle")
                        .font(.footnote)
                        .foregroundStyle(JournalTheme.subText)
                }
                .buttonStyle(.plain)
            }
        }
    }
}
