//
//  JournalEditorView.swift
//  Journal
//
//  Created by IOS EST on 11/16/26.
//

import SwiftUI
import SwiftData

struct JournalEditorView: View {
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    
    let journal: JournalDatabase?
    
    @State var title: String = ""
    @State var category: String = ""
    @State var tags: String = ""
    @State var content: String = ""
    
    @State var showingSaveError:Bool = false
    
    init(journal: JournalDatabase? = nil) {
        self.journal = journal
        _title = State(initialValue: journal?.title ?? "")
        _category = State(initialValue: journal?.category ?? "")
        _tags = State(initialValue: journal?.tags.joined(separator: ", ") ?? "")
        _content = State(initialValue: journal?.content ?? "")
    }
    
    var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // 배치 확인용 임시 값. 분류 선택 UI는 C 담당이므로 완성되면 교체한다.
    @State private var tagInput: String = ""
    private let suggestedCategories = ["업무", "공부", "운동", "관계"]
    private let suggestedTags = ["리뷰", "독서"]
    private let accent = JournalTheme.accent
    private let labelColor = JournalTheme.subText
    
    // tags 문자열("swift, 회고")을 칩으로 보여주기 위한 배열
    private var tagList: [String] {
        tags.split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                section("제목") {
                    TextField("오늘의 마이로그", text: $title)
                        .fieldStyle()
                }
                
                section("본문") {
                    TextEditor(text: $content)
                        .scrollContentBackground(.hidden)
                        .frame(height: 140)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .fieldBackground()
                        .overlay(alignment: .topLeading) {
                            if content.isEmpty {
                                Text("오늘 있었던 일과 느낀 점을 적어 보세요.")
                                    .foregroundStyle(labelColor.opacity(0.7))
                                    .padding(.horizontal, 17)
                                    .padding(.vertical, 16)
                                    .allowsHitTesting(false)
                            }
                        }
                }
                
                section("카테고리") {
                    TextField("직접 입력", text: $category)
                        .fieldStyle()
                    
                    FlowLayout(spacing: 8) {
                        ForEach(suggestedCategories, id: \.self) { name in
                            chip(name, isSelected: category == name) {
                                category = name
                            }
                        }
                    }
                }
                
                section("태그") {
                    FlowLayout(spacing: 8) {
                        ForEach(tagList, id: \.self) { tag in
                            removableTagChip(tag)
                        }
                    }
                    
                    HStack(spacing: 10) {
                        TextField("태그 입력", text: $tagInput)
                            .fieldStyle()
                            .onSubmit { addTag(tagInput) }
                        
                        Button {
                            addTag(tagInput)
                        } label: {
                            Text("추가")
                                .bold()
                                .foregroundStyle(.white)
                                .padding(.horizontal, 18)
                                .padding(.vertical, 14)
                                .background(accent, in: Capsule())
                        }
                    }
                    
                    FlowLayout(spacing: 8) {
                        ForEach(suggestedTags.filter { !tagList.contains($0) }, id: \.self) { tag in
                            chip("#\(tag)", isSelected: false) {
                                addTag(tag)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
        .scrollDismissesKeyboard(.interactively)
        .foregroundStyle(JournalTheme.text)
        .journalBackground()
        .navigationTitle(journal == nil ? "새 마이로그" : "마이로그 수정")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .tint(accent)
        .toolbar {
            // push 화면은 뒤로가기 버튼이 취소 역할을 하므로 취소 버튼은 두지 않는다.
            ToolbarItem(placement: .confirmationAction) {
                Button("저장"){
                    save()
                }
                .disabled(!isValid)
            }
        }
        .alert("저장하지 못했습니다.", isPresented: $showingSaveError) {
            Button("확인", role: .cancel) {
                
            }
        } message: {
            Text("입력한 내용은 그대로 유지됩니다. 잠시 후 다시 저장해 주세요")
        }
    }
    
    func save() {
        guard isValid else { return }
        
        let target = journal ?? JournalDatabase(title: "", content: "", category: "", tags: [""])
        
        target.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        target.category = category.trimmingCharacters(in: .whitespacesAndNewlines)
        target.tags = tags.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
        target.content = content.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if journal == nil {
            modelContext.insert(target)
        }
        
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            modelContext.rollback()
            showingSaveError = true
        }
    }
}

// MARK: - 배치용 보조 뷰

private extension JournalEditorView {
    func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(labelColor)
            content()
        }
    }
    
    func chip(_ text: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(text)
                .fontWeight(isSelected ? .bold : .regular)
                .foregroundStyle(isSelected ? Color.white : JournalTheme.chipText)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(isSelected ? accent : JournalTheme.glassFill, in: Capsule())
                .overlay(Capsule().stroke(JournalTheme.glassBorder, lineWidth: 1))
        }
    }
    
    func removableTagChip(_ tag: String) -> some View {
        Button {
            removeTag(tag)
        } label: {
            HStack(spacing: 6) {
                Text("#\(tag)").bold()
                Image(systemName: "xmark")
                    .font(.caption.weight(.semibold))
                    .opacity(0.7)
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(accent, in: Capsule())
        }
    }
    
    func addTag(_ raw: String) {
        let name = raw
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        guard !name.isEmpty, !tagList.contains(name) else { return }
        tags = (tagList + [name]).joined(separator: ", ")
        tagInput = ""
    }
    
    func removeTag(_ name: String) {
        tags = tagList.filter { $0 != name }.joined(separator: ", ")
    }
}

private extension View {
    func fieldBackground() -> some View {
        self
            .background(JournalTheme.glassFill, in: RoundedRectangle(cornerRadius: 20))
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(JournalTheme.glassBorder, lineWidth: 1))
    }
    
    func fieldStyle() -> some View {
        self
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .fieldBackground()
    }
}

/// 칩이 한 줄을 넘으면 다음 줄로 넘겨 배치하는 레이아웃
private struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var usedWidth: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x > 0 && x + size.width > maxWidth {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
            usedWidth = max(usedWidth, x - spacing)
        }
        return CGSize(width: usedWidth, height: y + rowHeight)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x > bounds.minX && x + size.width > bounds.maxX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

#Preview {
    NavigationStack {
        NavigationLink("작성") { JournalEditorView() }
    }
    .modelContainer(for: JournalDatabase.self, inMemory: true)
}

// MARK: - 작업 메모
//
// [디자인과 다른 점]
// - 취소 버튼: 디자인에는 왼쪽 "취소"가 있지만, push 화면은 `< 뒤로` 버튼이 그 역할을 하므로 두지 않았다.
//   디자인대로 "취소"를 쓰려면 push 대신 sheet 방식으로 바꿔야 한다.
// - 색상: 하드코딩하지 않고 JournalTheme(Assets.xcassets의 색상 세트)을 쓴다. 라이트/다크 모드가 자동으로 적용된다.
//   색을 바꾸려면 이 파일이 아니라 에셋의 색상 세트를 수정한다.
//
// [기존 로직과의 관계]
// - `save()`와 `init`은 수정하지 않았다.
// - 태그 칩은 `tags` 문자열("swift, 회고")을 쪼개서 보여 주고, 추가/삭제도 이 문자열을 고친다.
//   그래서 저장 쪽 코드는 바꿀 필요가 없다.
// - 카테고리/태그 칩 부분은 C 담당 영역과 겹친다. 배치 확인용 임시 구현이므로,
//   C의 선택 UI가 나오면 교체하거나 합친다.
// - `suggestedCategories`, `suggestedTags`는 임시 값이다.
//
// [남은 확인 사항]
// - `isValid`가 아직 제목만 검사한다. README 기준(제목 또는 본문이 비면 저장 불가)에 맞추려면 `content`도 확인해야 한다.
