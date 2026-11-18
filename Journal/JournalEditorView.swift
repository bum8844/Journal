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
    // 날짜(하루/기간). 새 글은 오늘 하루로 시작합니다.
    @State var period: JournalPeriodValue
    @State var photoData: Data?
    // 중요도. 새 글과 값이 없던 기존 글은 2단계(보통)입니다.
    @State var importance: ReflectionImportance

    @State var showingSaveError:Bool = false
    // 저장하는 동안(알림 권한 요청 포함) 저장 버튼을 막아 같은 글이 두 번 저장되지 않게 합니다.
    @State private var isSaving = false
    @State private var reminderAlertMessage: String?
    @State private var aiComment: String?
    @State private var aiCommentInput: ReflectionCommentInput?
    @State private var aiCommentError: String?
    @State private var aiCommentTask: Task<Void, Never>?

    init(journal: JournalDatabase? = nil) {
        self.journal = journal
        _title = State(initialValue: journal?.title ?? "")
        _category = State(initialValue: journal?.category ?? "")
        _tags = State(initialValue: journal?.tags ?? [])
        _content = State(initialValue: journal?.content ?? "")

        // 편집이면 저장된 형식·답변·기간·사진을 그대로 채웁니다.
        let savedFormat = journal?.effectiveFormat ?? .free
        _format = State(initialValue: savedFormat)
        let savedAnswers = journal.map { Self.savedAnswers(in: $0, format: savedFormat) } ?? []
        if journal != nil {
            _answersByFormat = State(initialValue: [savedFormat: savedAnswers])
        }
        // 날짜가 없는 기존 글은 최초 작성일을 보여 줍니다.
        _period = State(initialValue: JournalPeriodValue(
            isPeriod: journal?.isPeriod ?? false,
            startDate: journal?.startDate ?? journal?.createdAt,
            endDate: journal?.endDate
        ))
        _photoData = State(initialValue: journal?.photoData)
        _importance = State(initialValue: journal?.effectiveImportance ?? .normal)
        if let journal, let comment = journal.aiComment {
            _aiComment = State(initialValue: comment)
            _aiCommentInput = State(initialValue: ReflectionCommentInput(
                format: savedFormat.title,
                title: journal.title,
                body: savedFormat == .free ? journal.content : Self.composeContent(format: savedFormat, answers: savedAnswers)
            ))
        }
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

    private var hasBody: Bool {
        if format == .free {
            return !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        return answers.contains { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }

    var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && hasBody && period.isValid
    }

    /// 오늘의 경험·내일을 위한 정리 답변을 목록·검색·상세가 그대로 읽을 수 있도록 content 한 덩어리로 만듭니다.
    private var composedContent: String {
        Self.composeContent(format: format, answers: answers)
    }

    private static func savedAnswers(in journal: JournalDatabase, format: ReflectionFormat) -> [String] {
        format.questions.map { question in
            journal.answers.first { $0.question == question.key }?.text
                ?? journal.answers.first { $0.question == question.legacyKey }?.text
                ?? ""
        }
    }

    private static func composeContent(format: ReflectionFormat, answers: [String]) -> String {
        zip(format.questions, answers)
            .compactMap { question, answer -> String? in
                let text = answer.trimmingCharacters(in: .whitespacesAndNewlines)
                return text.isEmpty ? nil : "\(question.title)\n\(text)"
            }
            .joined(separator: "\n\n")
    }

    private var commentInput: ReflectionCommentInput {
        ReflectionCommentInput(format: format.title, title: title, body: format == .free ? content : composedContent)
    }

    private var currentAIComment: String? {
        aiCommentInput == commentInput ? aiComment : nil
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

                aiCommentSection

                JournalPeriodPicker(value: $period)

                JournalImportancePicker(importance: $importance, isPeriod: period.isPeriod)

                JournalPhotoPicker(photoData: $photoData)

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
                .disabled(!isValid || isSaving)
            }
        }
        // 알림을 예약하지 못해도 회고는 이미 저장된 상태입니다. 알려 준 뒤 화면을 닫습니다.
        .alert("종료 알림을 예약하지 못했어요", isPresented: Binding(
            get: { reminderAlertMessage != nil },
            set: { if !$0 { reminderAlertMessage = nil } }
        )) {
            Button("확인") { dismiss() }
        } message: {
            Text(reminderAlertMessage ?? "")
        }
        .alert("저장하지 못했습니다.", isPresented: $showingSaveError) {
            Button("확인", role: .cancel) {

            }
        } message: {
            Text("입력한 내용은 그대로 유지됩니다. 잠시 후 다시 저장해 주세요")
        }
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

    private var aiCommentSection: some View {
        section("AI 한마디") {
            if let currentAIComment {
                Text(currentAIComment)
                    .foregroundStyle(JournalTheme.text)
            }
            if let message = ReflectionCommentGenerator.unavailableMessage ?? aiCommentError {
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(JournalTheme.subText)
            }
            if aiCommentTask != nil {
                ProgressView("AI 한마디를 만드는 중…")
                    .font(.footnote)
            } else {
                Button {
                    generateAIComment()
                } label: {
                    Label(currentAIComment == nil ? "AI 한마디 생성" : "다시 생성", systemImage: "sparkles")
                        .font(.body.weight(.semibold))
                        .frame(maxWidth: .infinity, minHeight: 44)
                }
                .buttonStyle(.borderedProminent)
                .tint(JournalTheme.accent)
                .buttonBorderShape(.roundedRectangle(radius: 16))
                .disabled(!commentInput.canGenerate || isSaving || ReflectionCommentGenerator.unavailableMessage != nil)
            }
        }
        .onDisappear {
            aiCommentTask?.cancel()
        }
    }

    private func generateAIComment() {
        let input = commentInput
        aiCommentError = nil
        aiCommentTask = Task { @MainActor in
            defer { aiCommentTask = nil }
            do {
                let comment = try await ReflectionCommentGenerator.generate(for: input)
                guard !Task.isCancelled, input == commentInput else { return }
                aiCommentInput = input
                aiComment = comment
            } catch {
                guard !Task.isCancelled, input == commentInput else { return }
                aiCommentError = "AI 한마디를 만들지 못했어요. 다시 시도해 주세요."
            }
        }
    }

    func save() {
        guard isValid, !isSaving else { return }
        isSaving = true

        // 입력창에 쓰다 만 태그도 저장에 포함한다
        tags = JournalDatabase.tags(tags, adding: tagInput)
        tagInput = ""

        let target = journal ?? JournalDatabase(title: "", content: "", category: "", tags: [])

        target.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        target.category = JournalDatabase.normalizedCategory(category) ?? ""
        target.tags = tags
        let originalFormat = journal?.effectiveFormat
        let originalAnswers = journal.map { Self.savedAnswers(in: $0, format: format) }
        target.format = format
        if format == .free {
            target.content = content.trimmingCharacters(in: .whitespacesAndNewlines)
            target.answers = []
        } else if journal == nil || originalFormat != format || originalAnswers != answers {
            target.content = composedContent
            target.answers = zip(format.questions, answers).map {
                JournalDatabase.ReflectionAnswer(question: $0.key, text: $1.trimmingCharacters(in: .whitespacesAndNewlines))
            }
        }
        // 날짜 규칙: 하루는 startDate가 선택일이고 endDate는 비운다. 기간은 startDate~endDate다.
        target.isPeriod = period.isPeriod
        target.startDate = period.startDate
        target.endDate = period.savedEndDate
        target.photoData = photoData
        target.importance = importance
        target.aiComment = currentAIComment

        if journal == nil {
            modelContext.insert(target)
        }


        do {
            try modelContext.save()
            scheduleReminderAndClose(for: target)
        } catch {
            modelContext.rollback()
            isSaving = false
            showingSaveError = true
        }
    }
}

// MARK: - 보조 뷰

private extension JournalEditorView {
    /// 저장이 성공한 뒤 종료 알림을 맞춰 예약하고 화면을 닫습니다.
    /// 기간 회고 + 1단계만 예약하고, 그 외에는 남은 예약을 지웁니다. 권한이 거부돼도 회고는 저장된 상태로 둡니다.
    func scheduleReminderAndClose(for journal: JournalDatabase) {
        Task {
            let outcome = await PeriodReminderScheduler.shared.reconcile(journalID: journal.id, in: modelContext)
            if let message = outcome.alertMessage {
                isSaving = false
                reminderAlertMessage = message
            } else {
                dismiss()
            }
        }
    }

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
// - 자유는 본문 한 칸, 오늘의 경험·내일을 위한 정리은 질문별 입력칸이다. 형식마다 답변을 따로 들고 있다가 선택한 형식의 답변만 저장한다.
// - 오늘의 경험·내일을 위한 정리 답변은 answers(질문 이름 + 답변)에 저장하고, 목록·검색·상세가 그대로 읽도록 content에도 합쳐서 넣는다.
//
// [C 파트와의 연결]
// - 카테고리/태그 입력은 C의 JournalClassificationPicker를 쓴다. 태그는 [String] 배열 그대로 저장한다.
// - 추천 카테고리는 기본값(업무, 공부, 운동, 관계) + 이미 저장된 카테고리다. 추천 태그는 이미 저장된 태그다.
// - 카테고리는 비어 있어도 저장할 수 있다(README 기준은 제목·본문만 필수). 목록 필터에서는 빈 카테고리를 보여 주지 않는다.
//
// [기간·사진]
// - 날짜는 JournalPeriodPicker(value: $period), 사진은 JournalPhotoPicker(photoData: $photoData)를 쓴다.
// - 저장 버튼은 period.isValid(시작일이 오늘 이후이거나 종료일이 시작일보다 빠르면 false)로도 막는다.
// - 날짜 규칙(B): 하루 회고도 선택한 날짜를 startDate에 저장하고 endDate는 비운다. 기간 회고는 startDate~endDate다.
//   날짜가 없는 기존 글은 편집 화면에서 최초 작성일(createdAt)을 보여 주고, 저장하면 그 날짜가 startDate에 들어간다.
