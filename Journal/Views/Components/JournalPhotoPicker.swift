import SwiftUI
import PhotosUI
import ImageIO
import UIKit

/// 사진 한 장을 고르고 미리보기·교체·제거하는 UI. 사진은 선택 사항입니다.
///
/// 작성폼과는 `Data?` 하나로 주고받습니다. (nil이면 사진 없음)
/// - 편집할 때는 저장된 사진 데이터를 그대로 넘기면 미리보기에 표시됩니다.
/// - 제거하면 nil이 됩니다.
/// - 선택을 취소하거나 불러오기에 실패하면 기존 값을 바꾸지 않습니다.
/// 시스템 사진 선택 화면에서 고른 사진만 받으므로 사진 보관함 접근 권한이 필요하지 않습니다.
struct JournalPhotoPicker: View {
    @Binding var photoData: Data?

    @State private var isPickerPresented = false
    @State private var pickerItem: PhotosPickerItem?
    @State private var previewImage: UIImage?
    @State private var isLoading = false
    @State private var isShowingLoadError = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Button { isPickerPresented = true } label: {
                HStack(spacing: 10) {
                    Image(systemName: "photo")
                        .foregroundStyle(JournalTheme.accent)
                        .frame(width: 28, height: 28)
                        .background(JournalTheme.glassTint, in: RoundedRectangle(cornerRadius: 8))
                        .accessibilityHidden(true)
                    Text("사진")
                        .foregroundStyle(JournalTheme.text)
                    Spacer(minLength: 8)
                    if isLoading {
                        ProgressView()
                            .accessibilityLabel("사진 불러오는 중")
                    } else {
                        Text(previewImage == nil ? "추가" : "교체")
                            .foregroundStyle(JournalTheme.accent)
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(JournalTheme.accent)
                            .accessibilityHidden(true)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .frame(minHeight: 44)
                .contentShape(Rectangle())
                .fieldBackground()
            }
            .buttonStyle(.plain)
            .disabled(isLoading)
            .accessibilityLabel(previewImage == nil ? "사진 추가" : "사진 교체")

            if let previewImage {
                Image(uiImage: previewImage)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 156)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(JournalTheme.glassBorder, lineWidth: 1))
                    .accessibilityLabel("선택한 사진")

                Button("사진 제거", systemImage: "xmark") { photoData = nil }
                    .font(.subheadline)
                    .foregroundStyle(JournalTheme.accent)
                    .frame(minHeight: 44)
                    .buttonStyle(.plain)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .disabled(isLoading)
            }
        }
        // 사진만 고르게 하고 영상은 보이지 않게 합니다.
        .photosPicker(isPresented: $isPickerPresented, selection: $pickerItem, matching: .images)
        .onChange(of: pickerItem) { _, item in
            guard let item else { return }
            Task { await load(item) }
        }
        // 부모가 값을 바꿔도(편집 화면이 기존 사진을 넣거나 제거) 미리보기가 따라갑니다.
        .onChange(of: photoData, initial: true) { _, data in
            previewImage = data.flatMap { UIImage(data: $0) }
        }
        .alert("사진을 불러오지 못했어요", isPresented: $isShowingLoadError) {
            Button("확인", role: .cancel) {}
        } message: {
            Text("기존 사진은 그대로 유지돼요. 다시 선택해 주세요.")
        }
    }

    /// 선택한 사진을 줄여서 `photoData`에 넣습니다. 실패하면 기존 값을 그대로 둡니다.
    @MainActor
    private func load(_ item: PhotosPickerItem) async {
        isLoading = true
        defer {
            isLoading = false
            // 선택값을 비워 두어야 같은 사진을 다시 골라도 변경이 감지됩니다.
            pickerItem = nil
        }

        do {
            guard let original = try await item.loadTransferable(type: Data.self),
                  let resized = await JournalPhotoProcessor.resizedJPEGData(from: original) else {
                isShowingLoadError = true
                return
            }
            photoData = resized
        } catch {
            isShowingLoadError = true
        }
    }
}

/// 선택한 사진을 저장하기 좋은 크기의 JPEG로 바꿉니다.
enum JournalPhotoProcessor {
    /// 긴 변의 최대 픽셀 수 (팀 합의 전 초안)
    nonisolated static let maxPixelSize = 1600
    nonisolated static let jpegQuality: CGFloat = 0.8

    /// 백그라운드에서 변환합니다. 읽을 수 없는 데이터면 nil입니다.
    static func resizedJPEGData(
        from data: Data,
        maxPixelSize: Int = JournalPhotoProcessor.maxPixelSize,
        quality: CGFloat = JournalPhotoProcessor.jpegQuality
    ) async -> Data? {
        await Task.detached(priority: .userInitiated) {
            makeJPEG(from: data, maxPixelSize: maxPixelSize, quality: quality)
        }.value
    }

    /// - 사진에 적힌 회전 정보를 반영해 세로 사진이 눕지 않게 합니다.
    /// - 원본보다 크게 키우지 않습니다.
    /// - 다시 인코딩하므로 위치 같은 촬영 정보(EXIF)는 남지 않습니다.
    /// - 투명한 이미지는 흰 배경 위에 그려 검게 변하지 않게 합니다.
    nonisolated static func makeJPEG(from data: Data, maxPixelSize: Int, quality: CGFloat) -> Data? {
        guard let source = CGImageSourceCreateWithData(data as CFData, [kCGImageSourceShouldCache: false] as CFDictionary),
              CGImageSourceGetCount(source) > 0 else { return nil }

        var targetSize = maxPixelSize
        if let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any],
           let width = properties[kCGImagePropertyPixelWidth] as? Int,
           let height = properties[kCGImagePropertyPixelHeight] as? Int {
            targetSize = min(maxPixelSize, max(width, height))
        }

        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceThumbnailMaxPixelSize: targetSize
        ]
        guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else { return nil }

        let size = CGSize(width: cgImage.width, height: cgImage.height)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = true
        let image = UIGraphicsImageRenderer(size: size, format: format).image { context in
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            UIImage(cgImage: cgImage).draw(in: CGRect(origin: .zero, size: size))
        }
        return image.jpegData(compressionQuality: quality)
    }
}

#Preview("사진 없음") {
    @Previewable @State var photoData: Data?

    ScrollView {
        JournalPhotoPicker(photoData: $photoData).padding(20)
    }
    .journalBackground()
}

#Preview("사진 있음") {
    @Previewable @State var photoData: Data? = {
        let size = CGSize(width: 800, height: 600)
        return UIGraphicsImageRenderer(size: size).jpegData(withCompressionQuality: 0.8) { context in
            UIColor.systemTeal.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }()

    ScrollView {
        JournalPhotoPicker(photoData: $photoData).padding(20)
    }
    .journalBackground()
}
