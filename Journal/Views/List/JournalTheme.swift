//
//  JournalTheme.swift
//  Journal
//
//  리스트 화면에서 쓰는 색상 모음 (라이트 모드 시안 기준)
//

import SwiftUI

enum JournalTheme {
    /// 버튼, 선택된 칩에 쓰는 보라색
    static let accent = Color(red: 0.486, green: 0.302, blue: 1.0)
    /// 제목 등 진한 글자색
    static let titleText = Color(red: 0.17, green: 0.12, blue: 0.29)
    /// 날짜, 플레이스홀더 등 흐린 글자색
    static let secondaryText = Color(red: 0.36, green: 0.31, blue: 0.5)
    /// 카테고리 배지 배경
    static let badgeBackground = Color(red: 0.78, green: 0.70, blue: 0.97).opacity(0.6)

    /// 화면 배경 (위: 연보라 → 아래: 연한 살구색)
    static let background = LinearGradient(
        colors: [
            Color(red: 0.91, green: 0.85, blue: 1.0),
            Color(red: 0.96, green: 0.85, blue: 0.93),
            Color(red: 0.99, green: 0.91, blue: 0.86)
        ],
        startPoint: .top,
        endPoint: .bottom
    )
}
