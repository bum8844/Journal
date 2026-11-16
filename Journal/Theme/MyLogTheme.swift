import SwiftUI

extension Color {
    /// 0xRRGGBB 형식의 정수로 색을 만듭니다.
    init(hex: UInt32, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}

extension Color {
    /// 라이트 모드와 다크 모드에서 각각 다른 색을 쓰는 동적 색상
    init(light: Color, dark: Color) {
        self.init(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }
}

/// 글래스 그라데이션 디자인 값 (시안 G). 모든 색은 라이트와 다크 모드를 함께 정의합니다.
enum MyLogTheme {
    static let text = Color(light: Color(hex: 0x2D2347), dark: Color(hex: 0xF1EBFF))
    static let subText = Color(light: Color(hex: 0x6F6590), dark: Color(hex: 0xB2A8D0))
    static let accent = Color(light: Color(hex: 0x7C4DFF), dark: Color(hex: 0x8F69FF))
    static let chipText = Color(light: Color(hex: 0x4A3D73), dark: Color(hex: 0xD6CCF5))
    static let badgeText = Color(light: Color(hex: 0x5A2FD6), dark: Color(hex: 0xCDBBFF))

    static let glassFill = Color(light: Color.white.opacity(0.55), dark: Color.white.opacity(0.10))
    static let glassTint = Color(light: Color.white.opacity(0.4), dark: Color.white.opacity(0.05))
    static let glassBorder = Color(light: Color.white.opacity(0.8), dark: Color.white.opacity(0.18))
    static let glassShadow = Color(light: Color(hex: 0x7C4DFF, opacity: 0.15), dark: Color.black.opacity(0.35))

    /// 라이트: 라벤더 → 핑크 → 피치. 다크: 짙은 남보라 → 자주 → 와인
    static let background = LinearGradient(
        gradient: Gradient(stops: [
            .init(color: Color(light: Color(hex: 0xE8D9FF), dark: Color(hex: 0x1A1433)), location: 0),
            .init(color: Color(light: Color(hex: 0xFFD9EC), dark: Color(hex: 0x2C1A45)), location: 0.55),
            .init(color: Color(light: Color(hex: 0xFFE9D6), dark: Color(hex: 0x3A2036)), location: 1)
        ]),
        startPoint: UnitPoint(x: 0.3, y: 0),
        endPoint: UnitPoint(x: 0.7, y: 1)
    )
}

extension View {
    /// 화면 전체에 그라데이션 배경을 깝니다.
    func myLogBackground() -> some View {
        background { MyLogTheme.background.ignoresSafeArea() }
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
                shape.fill(MyLogTheme.glassTint)
            }
            .overlay { shape.strokeBorder(MyLogTheme.glassBorder, lineWidth: 1) }
            .shadow(color: MyLogTheme.glassShadow, radius: 12, y: 8)
    }
}
