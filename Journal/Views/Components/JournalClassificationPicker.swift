import SwiftUI

/// 분류 선택 UI. 카테고리 한 개와 태그 여러 개를 고릅니다.
/// ScrollView나 VStack 안에 그대로 넣어 쓰며, "카테고리", "태그" 두 묶음으로 표시됩니다.
struct JournalClassificationPicker: View {
    @Binding var category: String
    @Binding var tags: [String]
    /// 입력창에 남아 있는 태그 텍스트. 저장 시 부모 뷰가 함께 반영할 수 있도록 바깥에서 받습니다.
    @Binding var tagInput: String

    /// 추천으로 보여줄 기존 카테고리
    let categorySuggestions: [String]
    /// 추천으로 보여줄 기존 태그
    let tagSuggestions: [String]

    private var unselectedTagSuggestions: [String] {
        tagSuggestions.filter { !tags.contains($0) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            group("카테고리") {
                TextField("직접 입력", text: $category)
                    .fieldStyle()

                if !categorySuggestions.isEmpty {
                    FlowLayout(spacing: 8) {
                        ForEach(categorySuggestions, id: \.self) { name in
                            JournalChip(title: name, isSelected: category == name) {
                                category = name
                            }
                        }
                    }
                }
            }

            group("태그") {
                if !tags.isEmpty {
                    FlowLayout(spacing: 8) {
                        ForEach(tags, id: \.self) { tag in
                            JournalChip(title: "#\(tag)", isSelected: true, trailingSystemImage: "xmark") {
                                tags.removeAll { $0 == tag }
                            }
                        }
                    }
                }

                HStack(spacing: 10) {
                    TextField("태그 입력", text: $tagInput)
                        .textInputAutocapitalization(.never)
                        .submitLabel(.done)
                        .onSubmit(commitTagInput)
                        .fieldStyle()

                    JournalChip(title: "추가", isSelected: JournalDatabase.normalizedTag(tagInput) != nil, action: commitTagInput)
                        .disabled(JournalDatabase.normalizedTag(tagInput) == nil)
                }

                if !unselectedTagSuggestions.isEmpty {
                    FlowLayout(spacing: 8) {
                        ForEach(unselectedTagSuggestions, id: \.self) { tag in
                            JournalChip(title: "#\(tag)") { tags.append(tag) }
                        }
                    }
                }
            }
        }
    }

    private func group<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(JournalTheme.subText)
            content()
        }
    }

    private func commitTagInput() {
        tags = JournalDatabase.tags(tags, adding: tagInput)
        tagInput = ""
    }
}

#Preview {
    @Previewable @State var category = "업무"
    @Previewable @State var tags = ["swift"]
    @Previewable @State var tagInput = ""

    ScrollView {
        JournalClassificationPicker(
            category: $category,
            tags: $tags,
            tagInput: $tagInput,
            categorySuggestions: ["공부", "업무", "운동"],
            tagSuggestions: ["swift", "독서", "러닝"]
        )
        .padding(20)
    }
    .journalBackground()
}
