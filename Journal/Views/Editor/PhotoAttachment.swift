// [임시 확인용] 작성 화면에서 사진이(가) 저장·표시되는지 확인하려고 만든 간단한 폼입니다.
// 기간·사진 입력 담당이 만든 폼이 나오면 이 파일을 지우고 JournalEditorView의 연결 한 줄만 바꿉니다.

import SwiftUI
import PhotosUI

/// 사진 한 장을 사진 보관함에서 고르는 줄. 고른 사진은 아래에 미리 보여 주고 교체·제거할 수 있습니다.
/// 값은 바인딩(photoData)으로 작성 화면에 바로 전달됩니다.
struct PhotoAttachment: View {
    @Binding var photoData: Data?
    @State private var pickerItem: PhotosPickerItem?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // 줄을 누르면 사진 보관함이 열립니다. 이미 사진이 있으면 같은 줄로 교체합니다.
            PhotosPicker(selection: $pickerItem, matching: .images) {
                EditorOptionRow(systemImage: "photo", title: "사진", status: photoData == nil ? "추가" : "교체")
            }
            .buttonStyle(.plain)

            if let photoData, let image = UIImage(data: photoData) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                Button("사진 제거", role: .destructive) {
                    self.photoData = nil
                    pickerItem = nil
                }
                .font(.subheadline)
            }
        }
        .onChange(of: pickerItem) { _, item in
            guard let item else { return }
            Task {
                // 큰 원본을 그대로 저장하지 않도록 JPEG로 줄여 보관합니다.
                guard let data = try? await item.loadTransferable(type: Data.self),
                      let image = UIImage(data: data) else { return }
                photoData = image.jpegData(compressionQuality: 0.8) ?? data
            }
        }
    }
}

#Preview {
    @Previewable @State var photoData: Data?

    PhotoAttachment(photoData: $photoData)
        .padding(20)
        .journalBackground()
}
