import SwiftUI
#if os(iOS)
import UIKit
#endif

/// 설정 화면과 앱 루트가 공유하는 저장 키입니다.
enum DisplaySettings {
    static let textSizeKey = "appTextSize"
    static let usesCustomBrightnessKey = "usesCustomBrightness"
    static let brightnessKey = "appBrightness"
    static let initialBrightness = 0.5
}

enum AppTextSize: String, CaseIterable {
    case system
    case small
    case standard
    case large

    var title: String {
        switch self {
        case .system: "시스템 따르기"
        case .small: "작게"
        case .standard: "보통"
        case .large: "크게"
        }
    }

    var size: DynamicTypeSize? {
        switch self {
        case .system: nil
        case .small: .small
        case .standard: .large
        case .large: .xxLarge
        }
    }
}

/// 앱에서 선택한 글자 크기를 하위 화면에 전달합니다.
struct AppTextSizeModifier: ViewModifier {
    @AppStorage(DisplaySettings.textSizeKey) private var textSize: AppTextSize = .system
    @Environment(\.dynamicTypeSize) private var systemTextSize

    func body(content: Content) -> some View {
        content.dynamicTypeSize(textSize.size ?? systemTextSize)
    }
}

#if os(iOS)
/// Journal이 활성 상태일 때만 직접 조절 값을 적용합니다.
struct AppBrightnessModifier: ViewModifier {
    @AppStorage(DisplaySettings.usesCustomBrightnessKey) private var usesCustomBrightness = false
    @AppStorage(DisplaySettings.brightnessKey) private var brightness = DisplaySettings.initialBrightness
    @Environment(\.scenePhase) private var scenePhase
    @State private var adjustedScreen: UIScreen?
    @State private var originalBrightness: CGFloat?

    func body(content: Content) -> some View {
        content
            .onChange(of: scenePhase, initial: true) { updateBrightness() }
            .onChange(of: usesCustomBrightness) { updateBrightness() }
            .onChange(of: brightness) { updateBrightness() }
            .onDisappear { restoreBrightness() }
    }

    private func updateBrightness() {
        guard scenePhase == .active, usesCustomBrightness else {
            restoreBrightness()
            return
        }

        // 앱이 밝기를 바꾸기 직전 값을 보관합니다. 슬라이더를 움직여도 이 값은 유지합니다.
        if adjustedScreen == nil {
            let scene = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .first { $0.activationState == .foregroundActive && $0.windows.contains(where: \.isKeyWindow) }
            guard let screen = scene?.screen else { return }
            originalBrightness = screen.brightness
            adjustedScreen = screen
        }

        adjustedScreen?.brightness = CGFloat(min(max(brightness, 0), 1))
    }

    private func restoreBrightness() {
        if let adjustedScreen, let originalBrightness {
            adjustedScreen.brightness = originalBrightness
        }
        adjustedScreen = nil
        originalBrightness = nil
    }
}
#endif
