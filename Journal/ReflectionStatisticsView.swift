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
    @Environment(\.calendar) private var systemCalendar
    private var calendar: Calendar { ReflectionStatistics.reportingCalendar(from: systemCalendar) }
    @State private var period: Period = .month
    @State private var selectedDate = Date.now
    @Environment(\.scenePhase) private var scenePhase
    @State private var statisticsNow = Date.now
    @State private var selectedCategory: String?
    @State private var showsUntagged = false

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
                // 집계 기준은 기존 작성일입니다. 조회 범위 밖의 회고는 사진 데이터를 읽지 않습니다.
                let entries = reflections.compactMap { reflection -> StatisticsEntry? in
                    let date = reflection.createdAt
                    guard interval.start <= date, date < interval.end else { return nil }
                    return StatisticsEntry(
                        createdAt: date,
                        tags: reflection.tags,
                        category: reflection.category,
                        isPeriod: reflection.isPeriod,
                        hasPhoto: reflection.photoData?.isEmpty == false,
                        endDate: reflection.endDate,
                        importance: reflection.effectiveImportance.rawValue,
                        startDate: reflection.startDate
                    )
                }
                let statistics = ReflectionStatistics(entries: entries, interval: interval, calendar: calendar, now: statisticsNow)

                ReflectionStatisticsCharts(
                    statistics: statistics, calendar: calendar,
                    onSelectCategory: { selectedCategory = $0 },
                    onSelectUntagged: { showsUntagged = true }
                )
            }
        }
        // 팀 공통 테마: 시스템 목록 배경을 숨기고 그라데이션 배경과 유리 카드 행을 사용합니다.
        .scrollContentBackground(.hidden)
        .journalBackground()
        .foregroundStyle(JournalTheme.text)
        .tint(JournalTheme.accent)
        .navigationTitle("통계")
        .navigationDestination(item: $selectedCategory) { category in
            if let interval = selectedInterval {
                // 통계의 "미등록 > 분류"에서 들어온 목록이라 제목도 같은 말로 맞춘다
                matchingList(
                    title: category == JournalCategory.unclassified ? "분류 미등록" : JournalCategory.title(for: category),
                    in: interval, category: category
                )
            }
        }
        .navigationDestination(isPresented: $showsUntagged) {
            if let interval = selectedInterval {
                matchingList(title: "태그 미등록", in: interval, withoutTags: true)
            }
        }
        .task {
            // 화면이 열린 채로 날짜가 바뀌어도 종료 상태를 갱신한다.
            while !Task.isCancelled {
                statisticsNow = .now
                do { try await Task.sleep(for: .seconds(60)) }
                catch { return }
            }
        }
        .onChange(of: scenePhase) {
            if scenePhase == .active { statisticsNow = .now }
        }
        .onChange(of: period) {
            // 기간 단위를 바꾸면 이번 주 또는 이번 달부터 보여줍니다.
            selectedDate = .now
        }
    }

    /// 통계와 같은 작성일 범위·카테고리 규칙으로 원본 회고를 보여 줍니다.
    private func matchingList(title: String, in interval: DateInterval,
                              category: String? = nil, withoutTags: Bool = false) -> some View {
        let periodJournals = reflections.filter {
            interval.start <= $0.createdAt && $0.createdAt < interval.end
        }
        let journals = JournalDatabase.filter(periodJournals, category: category, tags: [], withoutTags: withoutTags)
            .sorted { $0.createdAt > $1.createdAt }

        return List {
            // 글이 있으면 작성일 구간 제목이 기간을 알려 주므로 기간 제목 줄을 따로 두지 않는다.
            // 글이 없을 때만 어느 기간인지 문구에 함께 적는다.
            if journals.isEmpty {
                Text("\(periodTitle(for: interval))에 해당하는 회고가 없어요.")
                    .foregroundStyle(JournalTheme.subText)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            }
            // 하루 회고 카드에는 날짜가 없어서, 목록과 같은 작성일 구간으로 나눠 언제 쓴 글인지 알 수 있게 한다
            ForEach(JournalDaySection.sections(from: journals)) { section in
                Section {
                    Text(section.title(now: statisticsNow, calendar: calendar))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(JournalTheme.subText)
                        .accessibilityAddTraits(.isHeader)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)

                    ForEach(section.journals) { journal in
                        NavigationLink {
                            JournalDetailView(journal: journal)
                        } label: {
                            JournalCardView(journal: journal)
                        }
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .journalBackground()
        .foregroundStyle(JournalTheme.text)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
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
