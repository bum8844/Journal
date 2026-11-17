import Foundation

extension JournalDatabase {
    /// 목록·상세에 보여 줄 날짜.
    /// 하루 회고는 날짜 하나, 기간 회고는 "시작일 ~ 종료일"입니다.
    /// 기간 회고인데 날짜가 비어 있으면 작성일을 대신 씁니다.
    var displayDateText: String {
        let style = Date.FormatStyle().year().month().day()
        guard isPeriod, let startDate, let endDate else {
            return (startDate ?? createdAt).formatted(style)
        }
        return "\(startDate.formatted(style)) ~ \(endDate.formatted(style))"
    }
}
