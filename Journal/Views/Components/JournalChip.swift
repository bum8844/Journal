import SwiftUI

/// 분류 선택 UI와 필터 UI가 함께 쓰는 알약형 칩 버튼
struct JournalChip: View {
    let title: String
    var isSelected = false
    /// 글자 뒤에 붙일 SF Symbol 이름. 선택된 태그의 삭제 표시 등에 씁니다.
    var trailingSystemImage: String?
    let action: () -> Void

    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(title)
                if let trailingSystemImage {
                    Image(systemName: trailingSystemImage)
                        .font(.caption.weight(.bold))
                        .opacity(0.8)
                }
            }
            .font(.body.weight(isSelected ? .semibold : .regular))
            .foregroundStyle(isSelected ? Color.white : JournalTheme.chipText)
            .padding(.horizontal, 16)
            .padding(.vertical, 9)
            .background(Capsule().fill(isSelected ? JournalTheme.accent : JournalTheme.glassFill))
            .overlay(Capsule().strokeBorder(JournalTheme.glassBorder, lineWidth: 1))
            .opacity(isEnabled ? 1 : 0.5)
        }
        // 목록·폼 행 안에서도 칩마다 따로 눌리도록 합니다.
        .buttonStyle(.plain)
    }
}
