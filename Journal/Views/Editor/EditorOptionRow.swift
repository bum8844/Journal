import SwiftUI

/// 시안의 하단 카드처럼 "아이콘 + 이름 + 오른쪽 상태 + 화살표"로 보이는 한 줄.
/// 버튼이나 PhotosPicker의 label 안에 넣어 씁니다.
struct EditorOptionRow: View {
    let systemImage: String
    let title: String
    let status: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .frame(width: 34, height: 34)
                .background(JournalTheme.accent, in: RoundedRectangle(cornerRadius: 10))

            Text(title)
                .foregroundStyle(JournalTheme.text)

            Spacer(minLength: 8)

            Text(status)
                .foregroundStyle(JournalTheme.subText)
            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(JournalTheme.subText)
        }
        .padding(.vertical, 10)
        .contentShape(Rectangle())
    }
}

#Preview {
    EditorOptionRow(systemImage: "photo", title: "사진", status: "추가")
        .padding(20)
        .journalBackground()
}
