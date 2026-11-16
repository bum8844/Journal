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
    }
}

#Preview {
    NavigationStack {
        JournalDetailView(journal: JournalDatabase.samples[0])
    }
}
