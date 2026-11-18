//
//  JournalDetailView.swift
//  Journal
//
//  회고 한 건의 상세 화면 (제목, 카테고리, 태그, 날짜, 본문)
//

import SwiftUI
import SwiftData

struct JournalDetailView: View {
    let journal: JournalDatabase
    // 수정 버튼을 누르면 같은 회고를 편집 화면으로 연다
    @State private var isEditing = false
    // 상세 화면 삭제 기능 추가: 확인을 받으면 저장소에서 지우고, 저장에 성공하면 화면을 닫는다
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var isConfirmingDelete = false
    // 삭제가 저장된 뒤에는 지워진 회고를 다시 읽지 않도록 내용을 숨긴다 (화면이 닫히기 전까지)
    @State private var isRemoved = false
    // 삭제를 저장하지 못했을 때 알려 주는 얼럿
    @State private var isShowingDeleteError = false

    var body: some View {
        ZStack {
            JournalTheme.background.ignoresSafeArea()

            if !isRemoved {
                ScrollView {
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack(alignment: .top) {
                                Text(journal.title)
                                    .font(.largeTitle.bold())
                                    .foregroundStyle(JournalTheme.text)

                                Spacer(minLength: 8)

                                Text(journal.category)
                                    .font(.footnote)
                                    .foregroundStyle(JournalTheme.badgeText)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 5)
                                    .background(Capsule().fill(JournalTheme.accent.opacity(0.15)))
                            }

                            if !journal.tags.isEmpty {
                                Text(journal.tags.map { "#\($0)" }.joined(separator: " "))
                                    .font(.subheadline)
                                    .foregroundStyle(JournalTheme.accent)
                            }

                            Text(journal.displayDateString)
                                .font(.subheadline)
                                .foregroundStyle(JournalTheme.subText)

                            Divider()

                            if let photoData = journal.photoData, let image = UIImage(data: photoData) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: .infinity)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                    .accessibilityLabel("첨부한 사진")
                            }

                            Text(journal.content)
                                .font(.body)
                                .foregroundStyle(JournalTheme.text)
                                .lineSpacing(6)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(24)
                        .glassCard(cornerRadius: 32)

                        if let comment = journal.aiComment {
                            VStack(alignment: .leading, spacing: 8) {
                                Label("AI 한마디", systemImage: "sparkles")
                                    .font(.headline)
                                    .foregroundStyle(JournalTheme.accent)
                                Text(comment)
                                    .foregroundStyle(JournalTheme.text)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(20)
                            .glassCard()
                        }
                    }
                    .padding(20)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .tint(JournalTheme.accent)
        .navigationDestination(isPresented: $isEditing) {
            JournalEditorView(journal: journal)
        }
        // 삭제 확인 창을 얼럿(alert)으로 표시
        .alert("이 회고를 삭제할까요?", isPresented: $isConfirmingDelete) {
            Button("삭제", role: .destructive) { deleteJournal() }
            Button("취소", role: .cancel) {}
        } message: {
            Text("삭제한 회고는 되돌릴 수 없어요.")
        }
        .alert(JournalDeletion.failureMessage, isPresented: $isShowingDeleteError) {
            Button("확인", role: .cancel) {}
        }
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    isEditing = true
                } label: {
                    Label("수정", systemImage: "pencil")
                }
                .buttonStyle(PressColorButtonStyle(pressed: .blue))

                Button(role: .destructive) {
                    // 삭제 버튼 연결: 바로 지우지 않고 확인 창을 먼저 띄운다
                    isConfirmingDelete = true
                } label: {
                    Label("삭제", systemImage: "trash")
                }
                .buttonStyle(PressColorButtonStyle(pressed: .red))
            }
        }
    }
}

private extension JournalDetailView {
    /// 회고를 지운다. 저장에 성공하면 종료 알림을 정리하고 화면을 닫는다.
    /// 실패하면 회고를 되돌리고 화면에 남아 얼럿을 보여 준다. (기존 알림 예약은 건드리지 않는다)
    func deleteJournal() {
        let journalID = journal.id
        guard JournalDeletion.delete(journal, in: modelContext) else {
            isShowingDeleteError = true
            return
        }
        isRemoved = true
        dismiss()
        // 삭제 저장이 성공한 뒤에만 종료 알림을 정리한다
        Task { _ = await PeriodReminderScheduler.shared.reconcile(journalID: journalID, in: modelContext) }
    }
}

/// 평소에는 테마 보라색, 누르는 동안에는 지정한 색으로 바뀌는 버튼 스타일
private struct PressColorButtonStyle: ButtonStyle {
    let pressed: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(configuration.isPressed ? pressed : JournalTheme.accent)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    NavigationStack {
        JournalDetailView(journal: JournalDatabase.samples[0])
    }
}
