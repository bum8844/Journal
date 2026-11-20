//
//  JournalDatabase+DebugSamples.swift
//  Journal
//
//  개발용(DEBUG 빌드) 확인 도구. 설정 탭의 "개발용" 섹션에서만 쓰고, Release 빌드에는 들어가지 않는다.
//  형식, 날짜 규칙, 중요도, 사진, 알림처럼 새 기능을 한 번에 확인할 수 있는 샘플을 넣고 지운다.
//

#if DEBUG
import Foundation
import SwiftData
#if canImport(UIKit)
import UIKit
#endif

extension JournalDatabase {
    /// 확인용 샘플. 날짜는 실행한 날을 기준으로 정해서, 넣을 때마다 "진행 중", "종료됨"과 목록 날짜 구간이 맞게 나온다.
    static func debugSamples(now: Date = .now) -> [JournalDatabase] {
        let calendar = Calendar.current
        func day(_ offset: Int) -> Date {
            calendar.date(byAdding: .day, value: offset, to: calendar.startOfDay(for: now)) ?? now
        }
        /// 형식의 질문 순서대로 답변을 만든다.
        func answers(_ format: ReflectionFormat, _ texts: [String]) -> [ReflectionAnswer] {
            zip(format.questions, texts).map { ReflectionAnswer(question: $0.key, text: $1) }
        }

        /// 에디터가 저장하는 방식과 같게, 질문 제목과 답변을 합쳐 content로 만든다.
        func composed(_ format: ReflectionFormat, _ texts: [String]) -> String {
            zip(format.questions, texts).map { "\($0.title)\n\($1)" }.joined(separator: "\n\n")
        }

        let fourLTexts = ["팀원들과 합친 뒤 빌드가 한 번에 통과했다.", "충돌은 작게 자주 풀수록 쉽다.", "문서 갱신이 늦었다.", "QA 항목이 더 구체적이면 좋겠다."]
        let tomorrowTexts = ["QA 문서의 기준 커밋을 갱신한다.", "AI 한마디를 실제 기기에서 확인한다.", "남은 정리 항목을 팀과 나눈다."]

        var items: [JournalDatabase] = []

        // 하루 회고: 형식별
        items.append(JournalDatabase(
            title: "[하루·자유] 오늘 한 일", content: "SwiftUI 목록 화면을 정리하고 빈 상태 화면을 붙였다.",
            category: "개발", tags: ["SwiftUI", "정리"], format: .free,
            isPeriod: false, startDate: day(0), importance: .normal))

        items.append(JournalDatabase(
            title: "[하루·4L] 팀 스프린트", content: composed(.fourL, fourLTexts),
            category: "프로젝트", tags: ["회고", "팀"], format: .fourL,
            answers: answers(.fourL, fourLTexts),
            isPeriod: false, startDate: day(-1), importance: .high))

        items.append(JournalDatabase(
            title: "[하루·내일] 내일 계획", content: composed(.tomorrow, tomorrowTexts),
            category: "계획", tags: ["내일"], format: .tomorrow,
            answers: answers(.tomorrow, tomorrowTexts),
            isPeriod: false, startDate: day(-2), importance: .low))

        // 기간 회고: 진행 중, 종료됨, 앞으로 시작, 중요도별 (1단계만 종료일 알림 대상)
        items.append(JournalDatabase(
            title: "[기간·진행 중·높음] 앱 마감 주간", content: "이번 주 안에 QA와 PR을 끝낸다.",
            category: "프로젝트", tags: ["마감", "QA"], format: .free,
            isPeriod: true, startDate: day(-2), endDate: day(3), importance: .high))

        items.append(JournalDatabase(
            title: "[기간·종료됨·높음] 지난 스프린트", content: "종료일이 지난 기간 회고. 알림은 예약되지 않아야 한다.",
            category: "프로젝트", tags: ["스프린트"], format: .free,
            isPeriod: true, startDate: day(-14), endDate: day(-7), importance: .high))

        items.append(JournalDatabase(
            title: "[기간·예정·보통] 다음 주 학습", content: "시작 전인 기간 회고.",
            category: "교육", tags: ["학습"], format: .free,
            isPeriod: true, startDate: day(5), endDate: day(11), importance: .normal))

        items.append(JournalDatabase(
            title: "[기간·낮음] 한 달 운동", content: "길게 이어지는 기간 회고.",
            category: "운동", tags: ["운동", "습관"], format: .free,
            isPeriod: true, startDate: day(-10), endDate: day(20), importance: .low))

        // 화면 경계 확인용
        items.append(JournalDatabase(
            title: "[긴 글] 아주 긴 제목을 넣어서 카드와 상세 화면에서 줄바꿈과 말줄임이 자연스러운지 확인하는 회고",
            content: String(repeating: "내용이 길어지는 경우를 확인하기 위한 문장입니다. ", count: 30),
            category: "확인", tags: ["긴글"], format: .free,
            isPeriod: false, startDate: day(-3), importance: .normal))

        items.append(JournalDatabase(
            title: "[태그 많음]", content: "태그가 많을 때 줄바꿈과 필터 바가 깨지지 않는지 확인한다.",
            category: "확인", tags: ["태그1", "태그2", "태그3", "태그4", "태그5", "태그6", "태그7", "태그8", "긴태그이름확인용"], format: .free,
            isPeriod: false, startDate: day(-4), importance: .normal))

        items.append(JournalDatabase(
            title: "[분류 없음]", content: "카테고리와 태그가 비어 있는 회고.",
            category: "", tags: [], format: .free,
            isPeriod: false, startDate: day(-5), importance: .normal))

        let withComment = JournalDatabase(
            title: "[AI 한마디 있음]", content: "AI 한마디가 저장된 회고가 상세 화면에 어떻게 보이는지 확인한다.",
            category: "확인", tags: ["AI"], format: .free,
            isPeriod: false, startDate: day(-6), importance: .normal)
        withComment.aiComment = "내일은 가장 작은 일 하나부터 끝내 보세요."
        items.append(withComment)

        // 옛 버전 글: 형식, 날짜, 중요도 값이 없다 (읽을 때 기본값으로 처리되는지 확인)
        let legacy = JournalDatabase(
            title: "[옛 글] 값이 없는 회고", content: "형식, 날짜, 중요도가 저장되지 않은 옛 버전 글.",
            category: "확인", tags: ["옛글"])
        legacy.format = nil
        legacy.importance = nil
        legacy.startDate = nil
        items.append(legacy)

        // 목록 구간(작성일) 확인용: 선택한 날짜와 작성일이 다른 글, 자정 경계, 오래된 글
        items.append(JournalDatabase(
            title: "[선택일≠작성일] 열흘 전 일을 오늘 작성", content: "하루 회고의 선택한 날짜(startDate)와 작성일(createdAt)이 다른 글.",
            category: "확인", tags: ["날짜"], format: .free,
            isPeriod: false, startDate: day(-10), importance: .normal))

        items.append(JournalDatabase(
            title: "[경계] 오늘 0시 직후 작성", content: "작성일이 오늘로 묶이는지 확인한다.",
            category: "확인", tags: ["경계"], format: .free,
            isPeriod: false, startDate: day(0), importance: .normal))

        items.append(JournalDatabase(
            title: "[경계] 어제 23:55 작성", content: "작성일이 어제로 묶이는지 확인한다.",
            category: "확인", tags: ["경계"], format: .free,
            isPeriod: false, startDate: day(-1), importance: .normal))

        items.append(JournalDatabase(
            title: "[작년·기간] 지난해 작성한 기간 회고", content: "지난해에 쓴 글. 구간 제목에 연도가 붙는지 확인한다.",
            category: "확인", tags: ["작년"], format: .free,
            isPeriod: true, startDate: day(-380), endDate: day(-370), importance: .low))

        items.append(JournalDatabase(
            title: "[선택일>작성일] 내일 일을 미리 작성", content: "선택한 날짜가 작성일보다 뒤인 하루 회고.",
            category: "확인", tags: ["날짜"], format: .free,
            isPeriod: false, startDate: day(1), importance: .normal))

        // 기간 회고인데 날짜가 비어 있는 글 (옛 데이터가 있어도 목록과 상세가 깨지지 않는지 확인)
        items.append(JournalDatabase(
            title: "[기간·날짜 없음] 날짜가 비어 있는 기간 회고", content: "기간 회고지만 시작일과 종료일이 저장되지 않은 글.",
            category: "확인", tags: ["날짜"], format: .free,
            isPeriod: true, startDate: nil, endDate: nil, importance: .normal))

        // 분류 없음, 태그 없음 확인용: 여러 날짜에 흩어 두어서, 어느 날짜에서도 필터로 모아 볼 수 있는지 확인한다.
        // (카테고리가 빈 값이면 화면에는 "분류없음"으로 보인다)
        items.append(JournalDatabase(
            title: "[분류X·태그X·오늘] 분류도 태그도 없는 글", content: "오늘 쓴 글. 카테고리와 태그가 모두 비어 있다.",
            category: "", tags: [], format: .free,
            isPeriod: false, startDate: day(0), importance: .normal))

        items.append(JournalDatabase(
            title: "[분류X·태그O·어제] 분류만 없는 글", content: "어제 쓴 글. 카테고리는 비어 있고 태그는 있다.",
            category: "", tags: ["메모"], format: .free,
            isPeriod: false, startDate: day(0), importance: .normal))

        items.append(JournalDatabase(
            title: "[분류O·태그X·3일 전] 태그만 없는 글", content: "3일 전에 쓴 글. 카테고리는 있고 태그는 없다.",
            category: "운동", tags: [], format: .free,
            isPeriod: false, startDate: day(0), importance: .normal))

        items.append(JournalDatabase(
            title: "[분류X·태그X·9일 전] 분류도 태그도 없는 글", content: "9일 전에 쓴 글.",
            category: "", tags: [], format: .free,
            isPeriod: false, startDate: day(0), importance: .normal))

        items.append(JournalDatabase(
            title: "[분류O·태그X·지난달] 태그만 없는 글", content: "지난달에 쓴 글.",
            category: "개발", tags: [], format: .free,
            isPeriod: false, startDate: day(0), importance: .normal))

        items.append(JournalDatabase(
            title: "[분류X·태그X·작년] 분류도 태그도 없는 글", content: "지난해에 쓴 글. 구간 제목에 연도가 붙는다.",
            category: "", tags: [], format: .free,
            isPeriod: false, startDate: day(0), importance: .normal))

        items.append(JournalDatabase(
            title: "[미분류 값·12일 전] 예전 이름으로 저장된 글", content: "카테고리가 직접 입력한 미분류인 옛 글. 분류없음으로 묶이는지 확인한다.",
            category: "미분류", tags: ["옛글"], format: .free,
            isPeriod: false, startDate: day(0), importance: .normal))

        // 어제와 저번 주(월~일, 통계의 주간 기준)에 분류 없음, 태그 없음이 있는 경우.
        // 주간 통계에서 이전 기간으로 이동해도 분류·태그 집계가 잡히는지 확인한다.
        items.append(JournalDatabase(
            title: "[분류X·태그X·어제] 어제 쓴 분류도 태그도 없는 글", content: "어제 쓴 글. 분류와 태그가 모두 없다.",
            category: "", tags: [], format: .free,
            isPeriod: false, startDate: day(0), importance: .normal))

        items.append(JournalDatabase(
            title: "[분류X·태그X·저번 주 월] 저번 주 월요일 글", content: "저번 주 월요일에 쓴 글.",
            category: "", tags: [], format: .free,
            isPeriod: false, startDate: day(0), importance: .normal))

        items.append(JournalDatabase(
            title: "[분류X·태그O·저번 주 수] 저번 주 수요일 글", content: "저번 주 수요일에 쓴 글. 분류만 없다.",
            category: "", tags: ["회고"], format: .free,
            isPeriod: false, startDate: day(0), importance: .normal))

        items.append(JournalDatabase(
            title: "[분류O·태그X·저번 주 금] 저번 주 금요일 글", content: "저번 주 금요일에 쓴 글. 태그만 없다.",
            category: "공부", tags: [], format: .free,
            isPeriod: false, startDate: day(0), importance: .normal))

        items.append(JournalDatabase(
            title: "[분류X·태그X·저번 주 일] 저번 주 일요일 글", content: "저번 주 일요일에 쓴 글. 주의 마지막 날 경계.",
            category: "", tags: [], format: .free,
            isPeriod: false, startDate: day(0), importance: .normal))

        items.append(JournalDatabase(
            title: "[분류O·태그O·저번 주 수] 분류와 태그가 모두 있는 글", content: "저번 주 수요일에 쓴 글. 비교용.",
            category: "개발", tags: ["swift"], format: .free,
            isPeriod: false, startDate: day(0), importance: .normal))

        #if canImport(UIKit)
        if let data = debugPhotoData() {
            items.append(JournalDatabase(
                title: "[사진 있음]", content: "사진이 목록과 상세에서 어떻게 보이는지 확인한다.",
                category: "확인", tags: ["사진"], format: .free,
                isPeriod: false, startDate: day(-7), photoData: data, importance: .normal))
        }
        #endif

        // 작성 시각(createdAt)을 여러 날에 걸쳐 나눠서, 목록의 날짜 구간(오늘·어제·이번 주·지난달·작년)을 확인한다.
        // 제목 앞부분이 같은 글에 시각을 맞춰 준다. (오늘 글은 지금보다 앞선 시각으로 둬서 미래 시각이 되지 않게 한다)
        func minutesAgo(_ minutes: Int) -> Date { now.addingTimeInterval(-Double(minutes) * 60) }
        func daysAgo(_ days: Int, hour: Int = 12, minute: Int = 0) -> Date {
            calendar.date(bySettingHour: hour, minute: minute, second: 0, of: day(-days)) ?? day(-days)
        }
        // 통계의 주간 기준(월요일 시작)으로 계산한 "저번 주". weekdayOffset 0 = 월요일, 6 = 일요일
        var reportingCalendar = calendar
        reportingCalendar.firstWeekday = 2
        let thisWeekStart = reportingCalendar.dateInterval(of: .weekOfYear, for: now)?.start ?? day(0)
        func lastWeek(_ weekdayOffset: Int, hour: Int = 12) -> Date {
            let start = reportingCalendar.date(byAdding: .day, value: weekdayOffset - 7, to: thisWeekStart) ?? thisWeekStart
            return reportingCalendar.date(bySettingHour: hour, minute: 0, second: 0, of: start) ?? start
        }
        let createdAtByTitlePrefix: [(prefix: String, date: Date)] = [
            // 오늘 (같은 날 안에서 최신순이 맞는지)
            ("[하루·자유]", minutesAgo(10)),
            ("[사진 있음]", minutesAgo(30)),
            ("[하루·4L]", minutesAgo(50)),
            ("[선택일≠작성일]", minutesAgo(70)),
            ("[선택일>작성일]", minutesAgo(90)),
            ("[경계] 오늘 0시 직후", calendar.date(byAdding: .minute, value: 5, to: day(0)) ?? now),
            ("[분류X·태그X·오늘]", minutesAgo(15)),
            // 어제
            ("[경계] 어제 23:55", calendar.date(byAdding: .minute, value: -5, to: day(0)) ?? now),
            ("[분류X·태그O·어제]", daysAgo(1, hour: 8)),
            ("[분류X·태그X·어제]", daysAgo(1, hour: 15)),
            ("[하루·내일]", daysAgo(1, hour: 21)),
            ("[기간·진행 중", daysAgo(1, hour: 10)),
            // 이번 주
            ("[기간·날짜 없음]", daysAgo(2)),
            ("[분류O·태그X·3일 전]", daysAgo(3, hour: 20)),
            ("[기간·종료됨", daysAgo(3, hour: 15)),
            ("[기간·예정", daysAgo(3, hour: 9)),
            ("[기간·낮음", daysAgo(6)),
            // 저번 주 (월~일)
            ("[분류X·태그X·저번 주 월]", lastWeek(0)),
            ("[분류X·태그O·저번 주 수]", lastWeek(2, hour: 10)),
            ("[분류O·태그O·저번 주 수]", lastWeek(2, hour: 18)),
            ("[분류O·태그X·저번 주 금]", lastWeek(4)),
            ("[분류X·태그X·저번 주 일]", lastWeek(6, hour: 23)),
            // 그 밖의 지난 글
            ("[분류X·태그X·9일 전]", daysAgo(9)),
            ("[미분류 값·12일 전]", daysAgo(12)),
            ("[긴 글]", daysAgo(8, hour: 18)),
            ("[태그 많음]", daysAgo(8, hour: 9)),
            // 지난달
            ("[분류O·태그X·지난달]", daysAgo(35)),
            ("[분류 없음]", daysAgo(40)),
            ("[AI 한마디 있음]", daysAgo(41)),
            // 지난해
            ("[작년·기간]", daysAgo(370)),
            ("[분류X·태그X·작년]", daysAgo(380)),
            ("[옛 글]", daysAgo(400))
        ]
        // 선택한 날짜가 작성일과 다른 샘플. 나머지 하루 회고는 작성일과 같은 날로 맞춰,
        // 카드에 날짜 줄이 나오지 않는 경우와 "날짜 회고"가 나오는 경우를 나눠서 확인한다.
        let differentDatePrefixes = ["[선택일≠작성일]", "[선택일>작성일]"]
        for item in items {
            if let match = createdAtByTitlePrefix.first(where: { item.title.hasPrefix($0.prefix) }) {
                item.createdAt = match.date
            }
            let keepsOwnDate = differentDatePrefixes.contains { item.title.hasPrefix($0) }
            if !item.isPeriod, item.startDate != nil, !keepsOwnDate {
                item.startDate = item.createdAt
            }
        }
        return items
    }

    #if canImport(UIKit)
    /// 사진 샘플용 이미지. 파일을 따로 두지 않으려고 그려서 만든다.
    private static func debugPhotoData() -> Data? {
        let size = CGSize(width: 1200, height: 800)
        let image = UIGraphicsImageRenderer(size: size).image { context in
            let colors = [UIColor.systemPink.cgColor, UIColor.systemPurple.cgColor, UIColor.systemOrange.cgColor] as CFArray
            if let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: nil) {
                context.cgContext.drawLinearGradient(
                    gradient, start: .zero, end: CGPoint(x: size.width, y: size.height), options: [])
            }
        }
        return image.jpegData(compressionQuality: 0.8)
    }
    #endif
}

/// 개발용 확인 도구. 넣고 지운 뒤에는 기간 회고의 종료일 알림도 저장소 상태에 맞게 다시 맞춘다.
enum JournalDebugTools {
    @MainActor
    static func insertSamples(in context: ModelContext) {
        let samples = JournalDatabase.debugSamples()
        samples.forEach { context.insert($0) }
        guard (try? context.save()) != nil else { return }
        reconcileReminders(for: samples.map(\.id), in: context)
    }

    @MainActor
    static func deleteAll(in context: ModelContext) {
        let journals = (try? context.fetch(FetchDescriptor<JournalDatabase>())) ?? []
        let ids = journals.map(\.id)
        journals.forEach { context.delete($0) }
        guard (try? context.save()) != nil else { return }
        reconcileReminders(for: ids, in: context)
    }

    @MainActor
    private static func reconcileReminders(for ids: [UUID], in context: ModelContext) {
        Task {
            for id in ids {
                _ = await PeriodReminderScheduler.shared.reconcile(journalID: id, in: context)
            }
        }
    }
}
#endif
