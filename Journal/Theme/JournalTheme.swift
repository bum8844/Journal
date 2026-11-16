import SwiftUI

/// 글래스 그라데이션 디자인 값 (시안 G).
/// 색상은 Assets.xcassets의 색상 세트에 라이트/다크 값이 함께 정의되어 있습니다.
/// 값을 바꾸려면 코드가 아니라 에셋의 색상 세트를 수정하세요.
enum JournalTheme {
    static let text = Color("ThemeText")
    static let subText = Color("ThemeSubText")
    static let accent = Color("AccentColor")
    static let chipText = Color("ThemeChipText")
    static let badgeText = Color("ThemeBadgeText")

    static let glassFill = Color("ThemeGlassFill")
    static let glassTint = Color("ThemeGlassTint")
    static let glassBorder = Color("ThemeGlassBorder")
    static let glassShadow = Color("ThemeGlassShadow")

    /// 라이트: 라벤더 → 핑크 → 피치. 다크: 짙은 남보라 → 자주 → 와인
    static let background = LinearGradient(
        gradient: Gradient(stops: [
            .init(color: Color("ThemeBackgroundTop"), location: 0),
            .init(color: Color("ThemeBackgroundMiddle"), location: 0.55),
            .init(color: Color("ThemeBackgroundBottom"), location: 1)
        ]),
        startPoint: UnitPoint(x: 0.3, y: 0),
        endPoint: UnitPoint(x: 0.7, y: 1)
    )
}

extension View {
    /// 화면 전체에 그라데이션 배경을 깝니다.
    func journalBackground() -> some View {
        background { JournalTheme.background.ignoresSafeArea() }
    }

    /// 반투명 유리 느낌의 카드 배경
    func glassCard(cornerRadius: CGFloat = 24) -> some View {
        modifier(GlassCard(cornerRadius: cornerRadius))
    }
}

private struct GlassCard: ViewModifier {
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        content
            .background {
                shape.fill(.ultraThinMaterial)
                shape.fill(JournalTheme.glassTint)
            }
            .overlay { shape.strokeBorder(JournalTheme.glassBorder, lineWidth: 1) }
            .shadow(color: JournalTheme.glassShadow, radius: 12, y: 8)
    }
}
