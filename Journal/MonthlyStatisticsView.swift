import SwiftUI
import SwiftData

/// 선택한 달을 관리하고 그 달의 회고 건수와 태그 빈도를 표시합니다.
struct MonthlyStatisticsView: View {
    // 앱의 SwiftData 컨테이너에서 회고를 읽고, 저장된 기록이 바뀌면 조회 결과를 갱신합니다.
    @Query private var reflections: [JournalDatabase]

    // 집계 기준과 월 이동에 같은 달력을 사용합니다. 첫 화면에서는 이번 달을 선택합니다.
    @Environment(\.calendar) private var calendar
    @State private var selectedMonth = Date.now

    var body: some View {
        // 집계에 필요한 작성일과 태그만 전달합니다. 조회 결과나 선택한 달이 바뀌면 다시 계산합니다.
        let entries = reflections.map {
            StatisticsEntry(createdAt: $0.createdAt, tags: $0.tags)
        }
        let statistics = MonthlyStatistics(entries: entries, month: selectedMonth, calendar: calendar)

        List {
            Section("월 선택") {
                HStack {
                    Button("이전 달", systemImage: "chevron.left") {
                        moveMonth(by: -1)
                    }
                    .labelStyle(.iconOnly)

                    Spacer()
                    Text(verbatim: selectedMonthTitle)
                        .multilineTextAlignment(.center)
                    Spacer()

                    Button("다음 달", systemImage: "chevron.right") {
                        moveMonth(by: 1)
                    }
                    .labelStyle(.iconOnly)
                    // 이번 달에 도달하면 다음 달 버튼을 비활성화합니다.
                    .disabled(calendar.compare(selectedMonth, to: .now, toGranularity: .month) != .orderedAscending)
                }
                .buttonStyle(.borderless)
            }

            Section("회고 건수") {
                Text("\(statistics.reflectionCount)건")
            }

            // 회고가 없거나 회고에 태그가 없는 달도 같은 빈 상태 문구로 안내합니다.
            Section("자주 쓴 태그") {
                if statistics.tagCounts.isEmpty {
                    Text("이 달에 등록된 태그가 없어요.")
                        .foregroundStyle(.secondary)
                }

                ForEach(statistics.tagCounts) { item in
                    LabeledContent(item.tag, value: "\(item.count)건")
                }
            }
        }
        .navigationTitle("월별 통계")
    }

    /// 기기 언어에 상관없이 월 선택 영역에 사용할 한국어 연·월을 만듭니다.
    private var selectedMonthTitle: String {
        let year = calendar.component(.year, from: selectedMonth)
        let month = calendar.component(.month, from: selectedMonth)
        return "\(year)년 \(month)월"
    }

    /// 월의 첫날을 기준으로 이동해 31일에서 짧은 달로 넘어갈 때도 의도한 달을 선택합니다.
    private func moveMonth(by offset: Int) {
        guard let monthStart = calendar.dateInterval(of: .month, for: selectedMonth)?.start,
              let targetMonth = calendar.date(byAdding: .month, value: offset, to: monthStart) else {
            return
        }
        selectedMonth = targetMonth
    }
}
