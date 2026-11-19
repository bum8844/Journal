import SwiftUI

/// 회고 날짜 입력값. 하루 회고(기본)와 기간 회고를 한 값으로 표현합니다.
///
/// SwiftData 모델을 모르는 순수 값 타입이라 작성폼이 `@State`로 들고 있다가
/// 저장할 때 모델의 `isPeriod`, `startDate`, `endDate`로 옮기면 됩니다. (저장 연결은 팀 규칙 확정 뒤)
/// - 하루 회고: `startDate`가 선택한 날짜이고 `endDate`는 저장하지 않습니다.
/// - 기간 회고: `startDate`~`endDate`입니다.
/// 날짜는 항상 그날 0시로 맞춰 시각 차이 때문에 같은 날이 달라 보이는 일을 막습니다.
struct JournalPeriodValue: Equatable {
    var isPeriod: Bool
    var startDate: Date
    var endDate: Date

    /// 저장을 막아야 하는 날짜 문제
    enum Problem: Equatable {
        case startInFuture
        case endBeforeStart

        var message: String {
            switch self {
            case .startInFuture: "하루 회고의 날짜는 오늘 이후로 정할 수 없어요."
            case .endBeforeStart: "종료일은 시작일보다 빠를 수 없어요."
            }
        }
    }

    /// 새 글의 기본값은 오늘 하루 회고입니다. 편집할 때는 기존 값을 넘겨 받습니다.
    init(
        isPeriod: Bool = false,
        startDate: Date? = nil,
        endDate: Date? = nil,
        calendar: Calendar = .current,
        now: Date = .now
    ) {
        let start = calendar.startOfDay(for: startDate ?? now)
        self.isPeriod = isPeriod
        self.startDate = start
        self.endDate = calendar.startOfDay(for: endDate ?? start)
    }

    /// 지금 값에 문제가 있으면 그 내용을, 없으면 nil을 돌려줍니다.
    func problem(calendar: Calendar = .current, now: Date = .now) -> Problem? {
        let start = calendar.startOfDay(for: startDate)
        // 하루 회고는 지나간 일을 적는 글이라 오늘까지만 고를 수 있다.
        // 기간 회고는 앞으로 시작할 기간(진행 전)도 쓸 수 있어서 시작일의 미래를 막지 않는다.
        if !isPeriod && start > calendar.startOfDay(for: now) { return .startInFuture }
        if isPeriod && calendar.startOfDay(for: endDate) < start { return .endBeforeStart }
        return nil
    }

    /// 작성폼의 저장 버튼 조건에 그대로 쓸 수 있습니다.
    var isValid: Bool { problem() == nil }

    /// 화면에 보여 줄 안내 문구
    var errorMessage: String? { problem()?.message }

    /// 모델에 저장할 종료일. 하루 회고는 nil입니다.
    var savedEndDate: Date? { isPeriod ? endDate : nil }
}

/// 하루 / 기간 선택과 날짜 입력 UI.
/// ScrollView나 VStack 안에 그대로 넣어 쓰며, 날짜 문제는 안내 문구로 보여 줍니다.
/// 저장을 막는 일은 부모(작성폼)가 `value.isValid`로 결정합니다.
struct JournalPeriodPicker: View {
    @Binding var value: JournalPeriodValue

    @Environment(\.calendar) private var calendar

    private var today: Date { calendar.startOfDay(for: .now) }

    // 피커는 허용 범위 밖의 값을 범위 안으로 맞춰 보여 줍니다. 잘못된 값이 들어와 있을 때
    // 안내 문구와 다른 날짜가 보이지 않도록, 현재 값이 범위 밖이면 그 값까지 범위를 넓혀 실제 값을 보여 줍니다.
    private var startUpperBound: Date { max(today, value.startDate) }
    private var endLowerBound: Date { min(value.startDate, value.endDate) }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("날짜")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(JournalTheme.subText)

            Picker("회고 기간", selection: periodBinding) {
                Text("하루").tag(false)
                Text("기간").tag(true)
            }
            .pickerStyle(.segmented)

            VStack(spacing: 0) {
                if value.isPeriod {
                    // 기간 회고는 시작일도 미래로 고를 수 있습니다. (진행 전 회고)
                    dateRow("시작", icon: "calendar", selection: startBinding, range: Date.distantPast...Date.distantFuture)
                    Divider().overlay(JournalTheme.glassBorder)
                    // 종료일은 시작일 이후만 고를 수 있습니다. 미래도 가능해서 진행 중인 회고를 쓸 수 있습니다.
                    dateRow("종료", icon: "calendar.badge.checkmark", selection: endBinding, range: endLowerBound...Date.distantFuture)
                } else {
                    dateRow("날짜", icon: "calendar", selection: startBinding, range: ...startUpperBound)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
            .fieldBackground()

            if let message = value.problem(calendar: calendar)?.message {
                Label(message, systemImage: "exclamationmark.circle")
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .accessibilityLabel("날짜 오류. \(message)")
            }
        }
    }

    private func dateRow(
        _ title: String, icon: String, selection: Binding<Date>, range: PartialRangeThrough<Date>
    ) -> some View {
        DatePicker(selection: selection, in: range, displayedComponents: .date) {
            dateLabel(title, icon: icon)
        }
        .environment(\.locale, Locale(identifier: "ko_KR"))
        .frame(minHeight: 44)
    }

    private func dateRow(
        _ title: String, icon: String, selection: Binding<Date>, range: ClosedRange<Date>
    ) -> some View {
        DatePicker(selection: selection, in: range, displayedComponents: .date) {
            dateLabel(title, icon: icon)
        }
        .environment(\.locale, Locale(identifier: "ko_KR"))
        .frame(minHeight: 44)
    }

    private func dateLabel(_ title: String, icon: String) -> some View {
        Label {
            Text(title)
        } icon: {
            Image(systemName: icon)
                .foregroundStyle(JournalTheme.accent)
                .accessibilityHidden(true)
        }
    }

    private var periodBinding: Binding<Bool> {
        Binding(get: { value.isPeriod }, set: setPeriod)
    }

    private var startBinding: Binding<Date> {
        Binding(
            get: { value.startDate },
            set: { value.startDate = calendar.startOfDay(for: $0) }
        )
    }

    private var endBinding: Binding<Date> {
        Binding(
            get: { value.endDate },
            set: { value.endDate = calendar.startOfDay(for: $0) }
        )
    }

    /// 하루에서 기간으로 바꿀 때 종료일이 시작일보다 빠르면 시작일로 맞춰 처음부터 오류가 뜨지 않게 합니다.
    private func setPeriod(_ isPeriod: Bool) {
        value.isPeriod = isPeriod
        if isPeriod && value.endDate < value.startDate {
            value.endDate = value.startDate
        }
    }
}

#Preview("하루 기본값") {
    @Previewable @State var value = JournalPeriodValue()

    ScrollView {
        JournalPeriodPicker(value: $value).padding(20)
    }
    .journalBackground()
}

#Preview("기간, 잘못된 날짜") {
    @Previewable @State var value = JournalPeriodValue(
        isPeriod: true,
        startDate: Calendar.current.date(byAdding: .day, value: -1, to: .now),
        endDate: Calendar.current.date(byAdding: .day, value: -5, to: .now)
    )

    ScrollView {
        JournalPeriodPicker(value: $value).padding(20)
    }
    .journalBackground()
}
