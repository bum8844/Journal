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
                            .foregroundStyle(JournalTheme.titleText)

                        Spacer(minLength: 8)

                        Text(journal.category)
                            .font(.footnote)
                            .foregroundStyle(JournalTheme.accent)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 5)
                            .background(Capsule().fill(JournalTheme.badgeBackground))
                    }

                    if !journal.tags.isEmpty {
                        Text(journal.tags.map { "#\($0)" }.joined(separator: " "))
                            .font(.subheadline)
                            .foregroundStyle(JournalTheme.accent)
                    }

                    Text(journal.createdAt.koreanDateString)
                        .font(.subheadline)
                        .foregroundStyle(JournalTheme.secondaryText)

                    Divider()

                    Text(journal.content)
                        .font(.body)
                        .foregroundStyle(JournalTheme.titleText)
                        .lineSpacing(6)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .fill(Color.white.opacity(0.45))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .stroke(Color.white.opacity(0.7), lineWidth: 1.5)
                )
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
