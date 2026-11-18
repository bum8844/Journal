import SwiftUI

/// 목록 카드에 중요도를 보여 주는 배지. 색 점 + 글자(높음·보통·낮음) 모양입니다.
struct ImportanceBadge: View {
    let importance: ReflectionImportance

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(dotColor)
                .frame(width: 8, height: 8)

            Text(importance.shortTitle)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(JournalTheme.text)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 5)
        .background(Capsule().fill(JournalTheme.glassFill))
        .overlay(Capsule().strokeBorder(JournalTheme.glassBorder, lineWidth: 1))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("중요도 \(importance.shortTitle)")
    }

    private var dotColor: Color {
        switch importance {
        case .high: JournalTheme.importanceHigh
        case .normal: JournalTheme.accent
        case .low: JournalTheme.importanceLow
        }
    }
}

#Preview {
    VStack(alignment: .trailing, spacing: 12) {
        ForEach(ReflectionImportance.allCases, id: \.self) { ImportanceBadge(importance: $0) }
    }
    .padding()
    .background(JournalTheme.background)
}
