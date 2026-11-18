import SwiftUI

/// 작성 화면 위쪽에 보이는 안내 박스. 제목과 두 줄 문구를 보여 줍니다.
struct FormatGuideBanner: View {
    let title: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "info.circle")
                .font(.body)
                .padding(.top, 3)

            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.title3.weight(.bold))
                Text(text)
                    .font(.subheadline)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .foregroundStyle(JournalTheme.chipText)
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(JournalTheme.accent.opacity(0.18), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    FormatGuideBanner(
        title: "나의 하루 돌아보기",
        text: "잠깐 멈춰, 오늘의 나를 만나보세요.\n한 줄씩만 적어도 충분해요."
    )
    .padding(20)
    .journalBackground()
}
