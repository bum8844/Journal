import SwiftUI

/// 작성 형식(오늘의 경험, 내일을 위한 정리, 자유)을 고르는 탭.
/// 선택된 탭은 흰 알약 모양으로 떠 보입니다.
struct FormatTabBar: View {
    @Binding var selection: ReflectionFormat

    var body: some View {
        HStack(spacing: 4) {
            ForEach(ReflectionFormat.displayOrder, id: \.self) { option in
                let isSelected = option == selection

                Button {
                    selection = option
                } label: {
                    Text(option.title)
                        .font(.subheadline.weight(isSelected ? .semibold : .regular))
                        .foregroundStyle(isSelected ? JournalTheme.text : JournalTheme.subText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 11)
                        .background {
                            if isSelected {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Color(uiColor: .systemBackground))
                                    .shadow(color: JournalTheme.glassShadow, radius: 4, y: 2)
                            }
                        }
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
        .padding(4)
        .fieldBackground()
    }
}

#Preview {
    @Previewable @State var selection: ReflectionFormat = .fourL

    FormatTabBar(selection: $selection)
        .padding(20)
        .journalBackground()
}
