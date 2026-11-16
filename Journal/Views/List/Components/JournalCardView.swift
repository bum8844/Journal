//
//  JournalCardView.swift
//  Journal
//
//  리스트에 표시되는 회고 카드 한 장
//

import SwiftUI

struct JournalCardView: View {
    let journal: JournalDatabase

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                Text(journal.title)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(JournalTheme.titleText)
                    .lineLimit(1)

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
                    .lineLimit(1)
            }

            Text(journal.createdAt.koreanDateString)
                .font(.subheadline)
                .foregroundStyle(JournalTheme.secondaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(Color.white.opacity(0.45))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .stroke(Color.white.opacity(0.7), lineWidth: 1.5)
        )
        .shadow(color: JournalTheme.accent.opacity(0.12), radius: 14, y: 6)
    }
}

#Preview {
    JournalCardView(journal: JournalDatabase.samples[0])
        .padding()
        .background(JournalTheme.background)
}
