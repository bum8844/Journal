import SwiftUI

/// 선택한 작성 형식(KPT·4L)의 설명을 보여 주는 안내 박스
struct FormatGuideBanner: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "info.circle")
            Text(text)
                .fixedSize(horizontal: false, vertical: true)
        }
        .font(.subheadline)
        .foregroundStyle(JournalTheme.chipText)
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(JournalTheme.accent.opacity(0.12), in: RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
    FormatGuideBanner(text: ReflectionFormat.fourL.guide ?? "")
        .padding(20)
        .journalBackground()
}
