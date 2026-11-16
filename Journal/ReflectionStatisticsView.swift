import SwiftUI
import SwiftData

/// 선택한 주 또는 달의 회고 건수와 태그 빈도를 표시합니다.
struct ReflectionStatisticsView: View {
    private enum Period: String, CaseIterable {
        case week = "주간"
        case month = "월간"

        var component: Calendar.Component {
            switch self {
            case .week: .weekOfYear
            case .month: .month
            }
        }
    }

    // 앱의 SwiftData 컨테이너에서 회고를 읽고, 저장된 기록이 바뀌면 조회 결과를 갱신합니다.
    @Query private var reflections: [JournalDatabase]
    @Environment(\.calendar) private var calendar
    @State private var period: Period = .month
    @State private var selectedDate = Date.now

    var body: some View {
        let selectedInterval = calendar.dateInterval(of: period.component, for: selectedDate)

        List {
            Section {
                Picker("통계 기간", selection: $period) {
                    ForEach(Period.allCases, id: \.self) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(.segmented)

                if let interval = selectedInterval {
                    HStack {
                        Button("이전 기간", systemImage: "chevron.left") {
                            movePeriod(by: -1, from: interval.start)
                        }
                        .labelStyle(.iconOnly)

                        Spacer()
                        Text(verbatim: periodTitle(for: interval))
                            .multilineTextAlignment(.center)
                        Spacer()

                        Button("다음 기간", systemImage: "chevron.right") {
                            movePeriod(by: 1, from: interval.start)
                        }
                        .labelStyle(.iconOnly)
                        .disabled(interval.end > .now)
                    }
                    .buttonStyle(.borderless)
                }
            }
            .listRowBackground(JournalTheme.glassFill)

            if let interval = selectedInterval {
                // 주·월간 화면 모두 같은 집계 코드에 선택한 기간과 작성일·태그를 넘깁니다.
                let entries = reflections.map {
                    StatisticsEntry(createdAt: $0.createdAt, tags: $0.tags)
                }
                let statistics = ReflectionStatistics(entries: entries, interval: interval)

                Section("회고 건수") {
                    Text("\(statistics.reflectionCount)건")
                }
                .listRowBackground(JournalTheme.glassFill)

                Section("자주 쓴 태그") {
                    if statistics.tagCounts.isEmpty {
                        Text("이 기간에 등록된 태그가 없어요.")
                            .foregroundStyle(JournalTheme.subText)
                    }

                    ForEach(statistics.tagCounts) { item in
                        LabeledContent(item.tag, value: "\(item.count)건")
                    }
                }
                .listRowBackground(JournalTheme.glassFill)
            }
        }
        // 팀 공통 테마: 시스템 목록 배경을 숨기고 그라데이션 배경과 유리 카드 행을 사용합니다.
        .scrollContentBackground(.hidden)
        .journalBackground()
        .foregroundStyle(JournalTheme.text)
        .tint(JournalTheme.accent)
        .navigationTitle("통계")
        .onChange(of: period) {
            // 기간 단위를 바꾸면 이번 주 또는 이번 달부터 보여줍니다.
            selectedDate = .now
        }
    }

    private func periodTitle(for interval: DateInterval) -> String {
        let start = interval.start
        let year = calendar.component(.year, from: start)
        let month = calendar.component(.month, from: start)
        let monthTitle = "\(year)년 \(month)월"

        guard period == .week,
              let lastDay = calendar.date(byAdding: .day, value: -1, to: interval.end) else {
            return monthTitle
        }

        // 기간 종료는 다음 주의 시작이므로, 화면에는 하루 앞 날짜까지 표시합니다.
        let startDay = calendar.component(.day, from: start)
        let endYear = calendar.component(.year, from: lastDay)
        let endMonth = calendar.component(.month, from: lastDay)
        let endDay = calendar.component(.day, from: lastDay)
        let endYearTitle = year == endYear ? "" : "\(endYear)년 "
        return "\(monthTitle) \(startDay)일 ~ \(endYearTitle)\(endMonth)월 \(endDay)일"
    }

    /// 선택한 기간의 첫날에서 주 또는 달 단위로 이동합니다.
    private func movePeriod(by offset: Int, from start: Date) {
        if let target = calendar.date(byAdding: period.component, value: offset, to: start) {
            selectedDate = target
        }
    }
}
