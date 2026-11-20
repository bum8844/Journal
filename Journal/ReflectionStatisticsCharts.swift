import Charts
import SwiftUI

/// 주간·월간 화면이 같은 집계 결과를 그래프와 건수로 표시합니다.
struct ReflectionStatisticsCharts: View {
    let statistics: ReflectionStatistics
    let calendar: Calendar
    let onSelectCategory: (String) -> Void
    let onSelectUntagged: () -> Void
    @Environment(\.dynamicTypeSize) private var textSize

    var body: some View {
        Section("회고 건수") {
            Text("\(statistics.reflectionCount)건")
                .font(.title2.bold())

            if statistics.reflectionCount > 0 {
                dailyChart
            } else {
                Text("이 기간에 작성한 회고가 없어요.")
                    .foregroundStyle(JournalTheme.subText)
            }
        }
        .listRowBackground(JournalTheme.glassFill)

        if statistics.reflectionCount > 0 {
            Section("회고 유형·사진") {
                countBar("하루 회고", count: statistics.singleDayCount)
                countBar("기간 회고", count: statistics.periodCount)
                countBar("사진 첨부", count: statistics.photoCount)
            }
            .listRowBackground(JournalTheme.glassFill)
        }

        Section {
            unregisteredRow("분류", count: statistics.unclassifiedCount) {
                onSelectCategory(JournalCategory.unclassified)
            }
            unregisteredRow("태그", count: statistics.untaggedCount, action: onSelectUntagged)
        } header: {
            Text("미등록")
        } footer: {
            Text("분류와 태그가 모두 없는 글은 두 항목에 모두 포함돼요.\n전체 건수에는 한 번만 세어요.")
        }
        .buttonStyle(.plain)
        .listRowBackground(JournalTheme.glassFill)

        Section("기간 회고 일정") {
            if statistics.periodCount == 0 {
                Text("이 기간에 작성한 기간 회고가 없어요.")
                    .foregroundStyle(JournalTheme.subText)
            } else {
                countBar("예정", count: statistics.upcomingPeriodCount, total: statistics.periodCount)
                countBar("진행 중", count: statistics.ongoingPeriodCount, total: statistics.periodCount)
                countBar("종료", count: statistics.endedPeriodCount, total: statistics.periodCount)
                if statistics.undatedPeriodCount > 0 {
                    LabeledContent("종료일 없음", value: "\(statistics.undatedPeriodCount)건")
                }
                Text("시작일 전은 예정, 시작일부터 종료일까지는 진행 중이에요. 종료일이 지나면 종료로 집계해요.")
                    .font(.footnote)
                    .foregroundStyle(JournalTheme.subText)
            }
        }
        .listRowBackground(JournalTheme.glassFill)

        Section("중요도") {
            if statistics.reflectionCount == 0 {
                Text("이 기간에 작성한 회고가 없어요.")
                    .foregroundStyle(JournalTheme.subText)
            } else {
                countBar("1 · 높음", count: statistics.importanceCounts[0])
                countBar("2 · 보통", count: statistics.importanceCounts[1])
                countBar("3 · 낮음", count: statistics.importanceCounts[2])
            }
        }
        .listRowBackground(JournalTheme.glassFill)

        Section("자주 쓴 태그") {
            if statistics.tagCounts.isEmpty {
                Text("이 기간에 등록된 태그가 없어요.")
                    .foregroundStyle(JournalTheme.subText)
            } else {
                tagChart
            }

            ForEach(statistics.tagCounts.dropFirst(5)) { item in
                LabeledContent(item.tag, value: "\(item.count)건")
            }
        }
        .listRowBackground(JournalTheme.glassFill)

        Section("카테고리 비율") {
            if statistics.categoryCounts.isEmpty {
                Text("이 기간에 작성한 회고가 없어요.")
                    .foregroundStyle(JournalTheme.subText)
            } else {
                categoryChart
            }
        }
        .listRowBackground(JournalTheme.glassFill)
    }

    /// 미등록 항목 한 줄. 0건이면 연하게 보이고 누를 수 없다. 누르면 해당 글 목록으로 이동한다.
    private func unregisteredRow(_ title: String, count: Int, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            LabeledContent(title) {
                HStack {
                    Text("\(count)건")
                    if count > 0 {
                        Image(systemName: "chevron.right").font(.caption)
                    }
                }
            }
        }
        .disabled(count == 0)
        .opacity(count == 0 ? 0.5 : 1)
    }

    // 같은 기간의 전체 회고를 기준으로 각 항목의 건수와 비중을 함께 표시합니다.
    private func countBar(_ title: String, count: Int, total: Int? = nil) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            LabeledContent(title, value: "\(count)건")
            ProgressView(value: Double(count), total: Double(max(total ?? statistics.reflectionCount, 1)))
                .tint(JournalTheme.accent)
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .combine)
    }

    private var dailyChart: some View {
        let days = statistics.dailyCounts
        // 주간은 날짜를 모두, 월간은 일부 눈금만 표시해 화면이 좁아도 겹치지 않게 합니다.
        let labelStep = days.count <= 7 ? (textSize.isAccessibilitySize ? 2 : 1) : 7
        let axisPositions = stride(from: 0, to: days.count, by: labelStep).map(Double.init)

        return Chart(days.indices, id: \.self) { index in
            let day = days[index]
            BarMark(
                x: .value("날짜 위치", Double(index)),
                y: .value("회고 건수", day.count),
                width: .fixed(days.count <= 7 ? 20 : 6)
            )
            .foregroundStyle(JournalTheme.accent)
            .accessibilityLabel(Text(verbatim: "\(calendar.component(.month, from: day.date))월 \(dayNumber(day.date))일"))
            .accessibilityValue(Text("\(day.count)건"))
        }
        .chartXScale(domain: -0.5...(Double(days.count) - 0.5))
        .chartXAxis {
            AxisMarks(values: axisPositions) { value in
                if let position = value.as(Double.self), days.indices.contains(Int(position)) {
                    AxisValueLabel {
                        Text(dayNumber(days[Int(position)].date))
                            .foregroundStyle(JournalTheme.subText)
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks(values: .automatic(minimumStride: 1, desiredCount: 4))
        }
        .frame(height: textSize.isAccessibilitySize ? 205 : 155)
        .accessibilityLabel("날짜별 회고 건수")
    }

    private var tagChart: some View {
        let topTags = statistics.tagCounts.prefix(5)
        let maximumCount = max(topTags.first?.count ?? 0, 1)

        return Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 12) {
            ForEach(topTags) { item in
                // 같은 행에서 이름, 막대, 건수를 배치해 축 라벨과 막대가 어긋나지 않게 합니다.
                GridRow {
                    Text(item.tag)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: 110, alignment: .leading)

                    Chart {
                        BarMark(
                            x: .value("회고 건수", item.count),
                            y: .value("태그", item.tag),
                            height: .fixed(10)
                        )
                        .cornerRadius(3)
                        .foregroundStyle(JournalTheme.accent)
                    }
                    // 모든 태그에 같은 척도를 적용해 막대 길이로 건수를 비교할 수 있습니다.
                    .chartXScale(domain: 0...maximumCount)
                    .chartXAxis(.hidden)
                    .chartYAxis(.hidden)
                    .frame(minWidth: 24, maxWidth: .infinity)
                    .frame(height: 12)
                    .accessibilityHidden(true)

                    Text("\(item.count)건")
                        .monospacedDigit()
                        .fixedSize()
                        .gridColumnAlignment(.trailing)
                }
                .accessibilityElement(children: .combine)
            }
        }
    }

    private var categoryChart: some View {
        // 항목이 많으면 상위 다섯 개와 나머지 합계로 구성합니다.
        let categories = statistics.categoryCounts
        let top = Array(categories.prefix(5))
        let remainingCount = categories.dropFirst(5).reduce(0) { $0 + $1.count }
        let slices = top.map { (name: $0.name, count: $0.count) }
            + (remainingCount > 0 ? [(name: "그 외", count: remainingCount)] : [])
        let colors: [Color] = [JournalTheme.accent, .teal, .pink, .indigo, .orange, .gray]

        return VStack(alignment: .leading, spacing: 12) {
            Chart(slices.indices, id: \.self) { index in
                SectorMark(
                    angle: .value("회고 건수", slices[index].count),
                    innerRadius: .ratio(0.62)
                )
                .foregroundStyle(colors[index])
            }
            .frame(height: 140)
            .accessibilityHidden(true)

            // 파이는 상위 다섯 개와 그 외로 묶되, 목록은 모든 카테고리를 열 수 있게 합니다.
            ForEach(Array(categories.enumerated()), id: \.element.id) { index, category in
                Button {
                    onSelectCategory(category.category)
                } label: {
                    LabeledContent {
                        HStack {
                            Text("\(category.count)건")
                            Image(systemName: "chevron.right").font(.caption)
                        }
                    } label: {
                        Label {
                            Text(category.name)
                        } icon: {
                            Circle()
                                .fill(colors[min(index, colors.count - 1)])
                                .frame(width: 9, height: 9)
                                .accessibilityHidden(true)
                        }
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityElement(children: .combine)
            }
        }
    }

    private func dayNumber(_ date: Date) -> String {
        String(calendar.component(.day, from: date))
    }
}
