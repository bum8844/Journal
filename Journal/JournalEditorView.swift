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
    // 작성 형식. 새 글은 자유 형식으로 시작합니다.
    @State var format: ReflectionFormat = .free
    // 형식마다 답변을 따로 들고 있어, 형식을 바꿔도 다른 형식의 입력이 섞이지 않습니다.
    @State var answersByFormat: [ReflectionFormat: [String]] = [:]
    // 기록 기간. 하루 회고면 isPeriod가 false이고 날짜는 저장하지 않습니다.
    @State var isPeriod: Bool = false
    @State var startDate: Date = Date()
    @State var endDate: Date = Date()
    @State var photoData: Data?
    @State var showingPeriodSheet: Bool = false
    
    @State var showingSaveError:Bool = false
    
    init(journal: JournalDatabase? = nil) {
        self.journal = journal
        _title = State(initialValue: journal?.title ?? "")
        _category = State(initialValue: journal?.category ?? "")
        _tags = State(initialValue: journal?.tags ?? [])
        _content = State(initialValue: journal?.content ?? "")
        
        // 편집이면 저장된 형식·답변·기간·사진을 그대로 채웁니다.
        let savedFormat = journal?.format ?? .free
        _format = State(initialValue: savedFormat)
        if let journal {
            // 저장된 답변을 질문 순서에 맞춰 펼칩니다. 답이 없는 질문은 빈 칸입니다.
            let texts = savedFormat.questions.map { question in
                journal.answers.first { $0.question == question.key }?.text ?? ""
            }
            _answersByFormat = State(initialValue: [savedFormat: texts])
        }
        _isPeriod = State(initialValue: journal?.isPeriod ?? false)
        _startDate = State(initialValue: journal?.startDate ?? Date())
        _endDate = State(initialValue: journal?.endDate ?? journal?.startDate ?? Date())
        _photoData = State(initialValue: journal?.photoData)
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
    
    /// 현재 형식의 답변. 질문 수보다 짧으면 빈 칸으로 채워 돌려줍니다.
    private var answers: [String] {
        let saved = answersByFormat[format] ?? []
        let count = format.questions.count
        return saved + Array(repeating: "", count: max(0, count - saved.count))
    }
    
    private var answersBinding: Binding<[String]> {
        Binding(
            get: { answers },
            set: { answersByFormat[format] = $0 }
        )
    }
    
    /// 종료일이 시작일보다 빠르면 저장하지 않습니다. 하루 회고는 항상 통과합니다.
    private var isPeriodValid: Bool {
        PeriodSheet.isValid(isPeriod: isPeriod, startDate: startDate, endDate: endDate)
    }
    
    /// 기간 줄 오른쪽에 보이는 현재 선택
    private var periodStatus: String {
        guard isPeriod else { return "하루" }
        return "\(startDate.koreanDateString) ~ \(endDate.koreanDateString)"
    }
    
    private var hasBody: Bool {
        if format == .free {
            return !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        return answers.contains { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }
    
    var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && hasBody && isPeriodValid
    }
    
    /// 질문 형식(오늘의 경험·내일을 위한 정리) 답변을 목록·검색·상세가 그대로 읽을 수 있도록 content 한 덩어리로 만듭니다.
    private var composedContent: String {
        zip(format.questions, answers)
            .compactMap { question, answer -> String? in
                let text = answer.trimmingCharacters(in: .whitespacesAndNewlines)
                return text.isEmpty ? nil : "\(question.title)\n\(text)"
            }
            .joined(separator: "\n\n")
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                FormatTabBar(selection: $format)
                
                FormatGuideBanner(
                    title: "나의 하루 돌아보기",
                    text: "잠깐 멈춰, 오늘의 나를 만나보세요.\n한 줄씩만 적어도 충분해요."
                )
                
                section("제목") {
                    TextField("오늘의 마이로그", text: $title)
                        .fieldStyle()
                }
                
                if format == .free {
                    freeContentSection
                } else {
                    QuestionCard(questions: format.questions, answers: answersBinding)
                }
                
                optionsCard
                
                JournalClassificationPicker(
                    category: $category,
                    tags: $tags,
                    tagInput: $tagInput,
                    categorySuggestions: categorySuggestions,
                    tagSuggestions: tagSuggestions
                )
                
                Text("완벽하지 않아도 괜찮은, 나의 기록")
                    .font(.subheadline)
                    .foregroundStyle(labelColor)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 8)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 32)
            .animation(.easeInOut(duration: 0.2), value: format)
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
                .fontWeight(.semibold)
                .buttonStyle(.borderedProminent)
                .disabled(!isValid)
            }
        }
        .sheet(isPresented: $showingPeriodSheet) {
            PeriodSheet(isPeriod: $isPeriod, startDate: $startDate, endDate: $endDate)
        }
        .alert("저장하지 못했습니다.", isPresented: $showingSaveError) {
            Button("확인", role: .cancel) {
                
            }
        } message: {
            Text("입력한 내용은 그대로 유지됩니다. 잠시 후 다시 저장해 주세요")
        }
    }
    
    /// 기간·사진 버튼이 들어 있는 카드. 기간 줄은 누르면 기간 선택 화면이, 사진 줄은 사진 보관함이 열립니다.
    private var optionsCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                showingPeriodSheet = true
            } label: {
                EditorOptionRow(systemImage: "calendar", title: "기록 기간", status: periodStatus)
            }
            .buttonStyle(.plain)
            
            Divider().overlay(JournalTheme.glassBorder)
            
            PhotoAttachment(photoData: $photoData)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
        .fieldBackground()
    }
    
    /// 자유 형식: 큰 본문 입력칸
    private var freeContentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            TextEditor(text: $content)
                .scrollContentBackground(.hidden)
                .frame(minHeight: 260)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .fieldBackground()
                .overlay(alignment: .topLeading) {
                    if content.isEmpty {
                        Text("오늘 하루를 자유롭게 적어보세요")
                            .foregroundStyle(labelColor.opacity(0.8))
                            .padding(.horizontal, 17)
                            .padding(.vertical, 16)
                            .allowsHitTesting(false)
                    }
                }
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
        target.format = format
        if format == .free {
            target.content = content.trimmingCharacters(in: .whitespacesAndNewlines)
            target.answers = []
        } else {
            target.content = composedContent
            target.answers = zip(format.questions, answers).map {
                JournalDatabase.ReflectionAnswer(question: $0.key, text: $1.trimmingCharacters(in: .whitespacesAndNewlines))
            }
        }
        target.isPeriod = isPeriod
        target.startDate = isPeriod ? startDate : nil
        target.endDate = isPeriod ? endDate : nil
        target.photoData = photoData
        
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
// - 위치 행은 만들지 않았다.
//
// [작성 형식]
// - 자유는 본문 한 칸, 오늘의 경험·내일을 위한 정리는 질문별 입력칸이다. 형식마다 답변을 따로 들고 있다가 선택한 형식의 답변만 저장한다.
// - 질문 형식의 답변은 answers(질문 이름 + 답변)에 저장하고, 목록·검색·상세가 그대로 읽도록 content에도 합쳐서 넣는다.
//
// [C 파트와의 연결]
// - 카테고리/태그 입력은 C의 JournalClassificationPicker를 쓴다. 태그는 [String] 배열 그대로 저장한다.
// - 추천 카테고리는 기본값(업무, 공부, 운동, 관계) + 이미 저장된 카테고리다. 추천 태그는 이미 저장된 태그다.
// - 카테고리는 비어 있어도 저장할 수 있다(README 기준은 제목·본문만 필수). 목록 필터에서는 빈 카테고리를 보여 주지 않는다.
//
// [기간·사진]
// - 기록 기간 줄은 PeriodSheet를, 사진 줄은 PhotoAttachment(사진 보관함)를 연다. 값은 바인딩으로 이 화면에 바로 들어온다.
// - 기간·사진 입력 담당이 만든 폼으로 바꿀 때는 optionsCard 안의 두 줄만 교체하면 된다.
// - 종료일이 시작일보다 빠르면 저장 버튼을 막는다. 하루 회고는 날짜를 저장하지 않는다.
