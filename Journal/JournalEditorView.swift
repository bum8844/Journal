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
    @State var tags: [String] = []
    @State var tagInput: String = ""
    @State var content: String = ""
    
    @State var showingSaveError:Bool = false
    
    init(journal: JournalDatabase? = nil) {
        self.journal = journal
        _title = State(initialValue: journal?.title ?? "")
        _category = State(initialValue: journal?.category ?? "")
        _tags = State(initialValue: journal?.tags ?? [])
        _content = State(initialValue: journal?.content ?? "")
    }
    
    var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // 추천 목록에 쓰기 위해 이미 저장된 회고를 읽는다
    @Query private var allJournals: [JournalDatabase]
    
    private let defaultCategories = ["업무", "공부", "운동", "관계"]
    private let labelColor = JournalTheme.subText
    
    /// 기본 카테고리 + 이미 쓴 카테고리 (중복 없이, 처음 나온 순서 유지)
    private var categorySuggestions: [String] {
        let existing = allJournals.map(\.category).filter { !$0.isEmpty }
        var seen = Set<String>()
        return (defaultCategories + existing).filter { seen.insert($0).inserted }
    }
    
    /// 이미 쓴 태그 (중복 없이, 처음 나온 순서 유지)
    private var tagSuggestions: [String] {
        var seen = Set<String>()
        return allJournals.flatMap(\.tags).filter { seen.insert($0).inserted }
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
                
                JournalClassificationPicker(
                    category: $category,
                    tags: $tags,
                    tagInput: $tagInput,
                    categorySuggestions: categorySuggestions,
                    tagSuggestions: tagSuggestions
                )
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
        .tint(JournalTheme.accent)
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
        
        // 입력창에 쓰다 만 태그도 저장에 포함한다
        tags = JournalDatabase.tags(tags, adding: tagInput)
        tagInput = ""
        
        let target = journal ?? JournalDatabase(title: "", content: "", category: "", tags: [])
        
        target.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        target.category = JournalDatabase.normalizedCategory(category) ?? ""
        target.tags = tags
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

// MARK: - 보조 뷰

private extension JournalEditorView {
    func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(labelColor)
            content()
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
//
// [C 파트와의 연결]
// - 카테고리/태그 입력은 C의 JournalClassificationPicker를 쓴다. 태그는 [String] 배열 그대로 저장한다.
// - 추천 카테고리는 기본값(업무, 공부, 운동, 관계) + 이미 저장된 카테고리다. 추천 태그는 이미 저장된 태그다.
// - 카테고리는 비어 있어도 저장할 수 있다(README 기준은 제목·본문만 필수). 목록 필터에서는 빈 카테고리를 보여 주지 않는다.
