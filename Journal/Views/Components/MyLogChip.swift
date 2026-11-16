import SwiftUI

/// 분류 선택 UI와 필터 UI가 함께 쓰는 칩 버튼
struct MyLogChip: View {
    let title: String
    var isSelected = false
    let action: () -> Void

    var body: some View {
        Button(title, action: action)
            .buttonStyle(.borderedProminent)
            .tint(isSelected ? .accentColor : .gray.opacity(0.3))
            .foregroundStyle(isSelected ? Color.white : Color.primary)
            .controlSize(.small)
    }
}
