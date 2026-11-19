import SwiftUI

/// 입력칸과 칩 영역이 함께 쓰는 공용 스타일.
/// 작성·편집 화면과 분류 선택기가 같은 모양을 쓰도록 한곳에 모았습니다.
extension View {
    /// 반투명 유리 느낌의 둥근 입력칸 배경과 테두리
    func fieldBackground() -> some View {
        self
            .background(JournalTheme.glassFill, in: RoundedRectangle(cornerRadius: 20))
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(JournalTheme.glassBorder, lineWidth: 1))
    }

    /// 한 줄 입력칸(TextField)에 쓰는 안쪽 여백 + 유리 배경
    func fieldStyle() -> some View {
        self
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .fieldBackground()
    }
}

/// 칩이 한 줄을 넘으면 다음 줄로 넘겨 배치하는 레이아웃
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    /// 줄바꿈을 정할 때 허용하는 오차. 칩 너비 합이 한 줄 너비와 거의 같을 때,
    /// 소수점 오차 때문에 마지막 칩이 다음 줄로 넘어가 높이 계산과 어긋나는 것을 막는다.
    private let tolerance: CGFloat = 0.5

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var usedWidth: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x > 0 && x + size.width > maxWidth + tolerance {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
            usedWidth = max(usedWidth, x - spacing)
        }
        // 너비가 정해져 있으면 그 너비를 그대로 보고한다. 칩이 쓴 너비만 보고하면
        // 배치할 때 한 줄 너비가 딱 맞아 줄바꿈이 달라질 수 있다.
        let width = proposal.width.map { $0.isFinite ? $0 : usedWidth } ?? usedWidth
        return CGSize(width: width, height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x > bounds.minX && x + size.width > bounds.maxX + tolerance {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}
