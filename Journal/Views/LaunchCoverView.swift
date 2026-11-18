//
//  LaunchCoverView.swift
//  Journal
//
//  앱이 켜진 직후 잠깐 보여 주는 커버 화면.
//  배경은 앱 테마(JournalTheme.background)를 그대로 써서 라이트/다크가 자동으로 맞고,
//  새싹은 투명 배경 이미지(CoverIcon)를 올린다.
//

import SwiftUI

struct LaunchCoverView: View {
    var body: some View {
        ZStack {
            JournalTheme.background

            // 이미지 안에서 새싹은 폭의 약 54%라서, 화면에서는 약 120pt로 보인다.
            Image("CoverIcon")
                .resizable()
                .scaledToFit()
                .frame(width: 220)
        }
        // 시스템 시작 화면은 새싹을 화면 정중앙에 놓는다.
        // 안전 영역을 무시해야 같은 위치에 겹친다.
        .ignoresSafeArea()
        // 잠깐 나오는 장식 화면이라 VoiceOver가 읽지 않게 한다.
        .accessibilityHidden(true)
    }
}

#Preview("라이트") {
    LaunchCoverView()
}

#Preview("다크") {
    LaunchCoverView()
        .preferredColorScheme(.dark)
}
