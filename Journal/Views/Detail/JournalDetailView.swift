//
//  JournalDetailView.swift
//  Journal
//
//  회고 한 건의 상세 화면 (제목, 카테고리, 태그, 날짜, 본문)
//

import SwiftUI

struct JournalDetailView: View {
    let journal: JournalDatabase

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

                    Text(journal.createdAt.koreanDateString)
                        .font(.subheadline)
                        .foregroundStyle(JournalTheme.subText)

                    Divider()

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
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                // 아직 동작은 연결하지 않았다 (수정 화면, 삭제는 이후에 연결)
                Button {
                    // TODO: 수정 화면으로 이동
                } label: {
                    Label("수정", systemImage: "pencil")
                }
                .buttonStyle(PressColorButtonStyle(pressed: .blue))

                Button(role: .destructive) {
                    // TODO: 삭제 후 목록으로 돌아가기
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
