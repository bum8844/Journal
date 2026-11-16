//
//  FilterChipView.swift
//  Journal
//
//  카테고리/태그 필터에 쓰는 알약 모양 버튼
//

import SwiftUI

struct FilterChipView: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.body)
                .foregroundStyle(isSelected ? Color.white : JournalTheme.chipText)
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .background(
                    Capsule().fill(isSelected ? JournalTheme.accent : JournalTheme.glassFill)
                )
                .overlay(
                    Capsule().strokeBorder(JournalTheme.glassBorder, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HStack {
        FilterChipView(title: "전체", isSelected: true) {}
        FilterChipView(title: "교육", isSelected: false) {}
    }
    .padding()
    .background(JournalTheme.background)
}
