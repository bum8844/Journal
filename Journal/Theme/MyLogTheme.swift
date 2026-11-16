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

/// 글래스 그라데이션 디자인 값 (시안 G)
enum MyLogTheme {
    static let text = Color(hex: 0x2D2347)
    static let subText = Color(hex: 0x6F6590)
    static let accent = Color(hex: 0x7C4DFF)
    static let chipText = Color(hex: 0x4A3D73)
    static let badgeText = Color(hex: 0x5A2FD6)

    static let glassFill = Color.white.opacity(0.55)
    static let glassBorder = Color.white.opacity(0.8)
    static let glassShadow = accent.opacity(0.15)

    /// 라벤더 → 핑크 → 피치로 번지는 배경
    static let background = LinearGradient(
        gradient: Gradient(stops: [
            .init(color: Color(hex: 0xE8D9FF), location: 0),
            .init(color: Color(hex: 0xFFD9EC), location: 0.55),
            .init(color: Color(hex: 0xFFE9D6), location: 1)
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
                shape.fill(Color.white.opacity(0.4))
            }
            .overlay { shape.strokeBorder(MyLogTheme.glassBorder, lineWidth: 1) }
            .shadow(color: MyLogTheme.glassShadow, radius: 12, y: 8)
    }
}
