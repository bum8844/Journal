//
//  DebugToolsSection.swift
//  Journal
//
//  설정 탭 맨 아래에 붙는 "개발용" 섹션. DEBUG 빌드에서만 컴파일되어 Release에는 나타나지 않는다.
//

#if DEBUG
import SwiftUI
import SwiftData

struct DebugToolsSection: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var journals: [JournalDatabase]
    @State private var isConfirmingDeleteAll = false

    var body: some View {
        Section {
            Button("확인용 샘플 넣기") {
                JournalDebugTools.insertSamples(in: modelContext)
            }

            Button("회고 전체 삭제", role: .destructive) {
                isConfirmingDeleteAll = true
            }
            .disabled(journals.isEmpty)
        } header: {
            Text("개발용 (DEBUG)")
        } footer: {
            Text("저장된 회고 \(journals.count)개. 이 섹션은 Release 빌드에는 나타나지 않아요.")
        }
        .listRowBackground(JournalTheme.glassFill)
        .confirmationDialog("저장된 회고를 모두 삭제할까요?", isPresented: $isConfirmingDeleteAll, titleVisibility: .visible) {
            Button("모두 삭제", role: .destructive) {
                JournalDebugTools.deleteAll(in: modelContext)
            }
        }
    }
}
#endif
