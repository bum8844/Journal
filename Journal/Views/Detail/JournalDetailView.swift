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
    // 삭제는 확인을 받은 뒤, 화면이 닫힌 다음에 저장소에서 지운다
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var isConfirmingDelete = false
    @State private var shouldDeleteOnDisappear = false

    var body: some View {
        ZStack {
            JournalTheme.background.ignoresSafeArea()

            ScrollView {
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
                .padding(20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .tint(JournalTheme.accent)
        .navigationDestination(isPresented: $isEditing) {
            JournalEditorView(journal: journal)
        }
        .confirmationDialog("이 회고를 삭제할까요?", isPresented: $isConfirmingDelete, titleVisibility: .visible) {
            Button("삭제", role: .destructive) {
                shouldDeleteOnDisappear = true
                dismiss()
            }
            Button("취소", role: .cancel) {}
        } message: {
            Text("삭제한 회고는 되돌릴 수 없어요.")
        }
        // 화면이 사라진 뒤에 지워야, 지워진 데이터를 이 화면이 다시 읽다가 문제가 생기지 않는다
        .onDisappear {
            guard shouldDeleteOnDisappear else { return }
            modelContext.delete(journal)
            try? modelContext.save()
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
                    isConfirmingDelete = true
                } label: {
                    Label("삭제", systemImage: "trash")
                }
                .buttonStyle(PressColorButtonStyle(pressed: .red))
            }
        }
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
