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
    /// 확인용 샘플. 날짜는 실행한 날을 기준으로 정해서, 넣을 때마다 "진행 중", "종료됨"이 맞게 나온다.
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

        #if canImport(UIKit)
        if let data = debugPhotoData() {
            items.append(JournalDatabase(
                title: "[사진 있음]", content: "사진이 목록과 상세에서 어떻게 보이는지 확인한다.",
                category: "확인", tags: ["사진"], format: .free,
                isPeriod: false, startDate: day(-7), photoData: data, importance: .normal))
        }
        #endif

        // 최신순 정렬이 항상 같은 순서가 되도록 작성 시각을 1분씩 어긋나게 한다
        for (index, item) in items.enumerated() {
            item.createdAt = now.addingTimeInterval(-Double(index) * 60)
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
