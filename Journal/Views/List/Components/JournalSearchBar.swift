//
//  JournalSearchBar.swift
//  Journal
//
//  제목, 본문, 카테고리, 태그를 검색하는 입력창
//

import SwiftUI

struct JournalSearchBar: View {
    @Binding var text: String
    var isFocused: FocusState<Bool>.Binding

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.title3)
                .foregroundStyle(JournalTheme.subText)

            TextField(
                "",
                text: $text,
                prompt: Text("제목, 본문, 카테고리, 태그 검색")
                    .foregroundStyle(JournalTheme.subText.opacity(0.6))
            )
            .focused(isFocused)
            .tint(JournalTheme.accent)
            .submitLabel(.search)
        }
        .padding(.horizontal, 18)
        .frame(height: 56)
        .glassCard(cornerRadius: 28)
    }
}

#Preview {
    @Previewable @State var text = ""
    @Previewable @FocusState var focused: Bool
    JournalSearchBar(text: $text, isFocused: $focused)
        .padding()
        .background(JournalTheme.background)
}
