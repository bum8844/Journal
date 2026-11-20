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
                    .foregroundStyle(JournalTheme.text)
                    .lineLimit(1)

                Spacer(minLength: 8)

                Text(JournalCategory.title(for: journal.category))
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
                    .lineLimit(1)
            }

            HStack {
                // 기간 회고(또는 작성일과 다른 날짜의 하루 회고)만 날짜를 보여 준다.
                // 그 외에는 목록의 구간 제목이 작성일을 대신한다.
                if let dateText = journal.listDateText {
                    Text(dateText)
                        .font(.subheadline)
                        .foregroundStyle(JournalTheme.subText)
                }

                Spacer(minLength: 8)

                // 사진이 있는 회고는 중요도 배지 앞에 사진 아이콘을 보여 줍니다.
                if journal.photoData != nil {
                    Image(systemName: "photo")
                        .font(.subheadline)
                        .foregroundStyle(JournalTheme.accent)
                        .accessibilityLabel("사진 포함")
                }

                // 작성 화면에서 고른 중요도(없으면 보통)를 날짜 줄 오른쪽에 보여 줍니다.
                ImportanceBadge(importance: journal.effectiveImportance)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .glassCard(cornerRadius: 32)
    }
}

#Preview {
    JournalCardView(journal: JournalDatabase.samples[0])
        .padding()
        .background(JournalTheme.background)
}
