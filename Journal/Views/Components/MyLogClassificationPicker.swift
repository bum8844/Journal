import SwiftUI

/// 분류 선택 UI. 카테고리 한 개와 태그 여러 개를 고릅니다.
/// `Form` 안에 넣으면 "카테고리", "태그" 두 섹션으로 표시됩니다.
struct MyLogClassificationPicker: View {
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
        Section("카테고리") {
            TextField("카테고리 직접 입력", text: $category)

            if !categorySuggestions.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(categorySuggestions, id: \.self) { name in
                            MyLogChip(title: name, isSelected: category == name) {
                                category = name
                            }
                        }
                    }
                }
            }
        }
        .listRowBackground(MyLogTheme.glassFill)

        Section("태그") {
            if !tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(tags, id: \.self) { tag in
                            MyLogChip(title: "#\(tag)", isSelected: true, trailingSystemImage: "xmark") {
                                tags.removeAll { $0 == tag }
                            }
                        }
                    }
                }
            }

            HStack {
                TextField("태그 입력", text: $tagInput)
                    .textInputAutocapitalization(.never)
                    .submitLabel(.done)
                    .onSubmit(commitTagInput)
                MyLogChip(title: "추가", isSelected: MyLog.normalizedTag(tagInput) != nil, action: commitTagInput)
                    .disabled(MyLog.normalizedTag(tagInput) == nil)
            }

            if !unselectedTagSuggestions.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(unselectedTagSuggestions, id: \.self) { tag in
                            MyLogChip(title: "#\(tag)") { tags.append(tag) }
                        }
                    }
                }
            }
        }
        .listRowBackground(MyLogTheme.glassFill)
    }

    private func commitTagInput() {
        tags = MyLog.tags(tags, adding: tagInput)
        tagInput = ""
    }
}
