import SwiftUI
import AVFoundation
import Photos
import PhotosUI
import UIKit
import DSKit

struct ImageAttachmentPicker: View {
    let image: UIImage?
    let emptyTitle: String
    let emptySubtitle: String
    let selectedBadgeTitle: String
    let cameraButtonTitle: String
    let libraryButtonTitle: String
    let height: CGFloat
    let onImageSelected: (UIImage) -> Void

    @State private var photoPickerItem: PhotosPickerItem?
    @State private var isCameraPresented = false
    @State private var isLibraryPresented = false
    @State private var feedbackMessage: String?
    @State private var isSettingsActionVisible = false

    init(
        image: UIImage?,
        emptyTitle: String,
        emptySubtitle: String,
        selectedBadgeTitle: String = "선택됨",
        cameraButtonTitle: String = "사진 찍기",
        libraryButtonTitle: String = "앨범에서 선택",
        height: CGFloat,
        onImageSelected: @escaping (UIImage) -> Void
    ) {
        self.image = image
        self.emptyTitle = emptyTitle
        self.emptySubtitle = emptySubtitle
        self.selectedBadgeTitle = selectedBadgeTitle
        self.cameraButtonTitle = cameraButtonTitle
        self.libraryButtonTitle = libraryButtonTitle
        self.height = height
        self.onImageSelected = onImageSelected
    }

    var body: some View {
        VStack(spacing: .jsSM) {
            preview

            HStack(spacing: .jsSM) {
                cameraButton
                libraryButton
            }

            if let feedbackMessage {
                VStack(alignment: .leading, spacing: .jsXS) {
                    RedesignInlineErrorView(
                        model: InlineErrorModel(message: feedbackMessage)
                    )

                    if isSettingsActionVisible {
                        Button(action: openSettings) {
                            HStack(spacing: .jsXS) {
                                Image(systemName: "gearshape.fill")
                                    .font(.jsLabelLarge)
                                    .accessibilityHidden(true)
                                Text("설정에서 허용하기")
                                    .font(.jsButtonSmall)
                            }
                            .foregroundColor(.primaryNormal)
                        }
                        .buttonStyle(.plain)
                        .jsTouchTarget()
                        .accessibilityLabel("설정에서 허용하기")
                        .accessibilityHint("iOS 설정 앱을 열어 사진 또는 카메라 권한을 변경합니다")
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .sheet(isPresented: $isCameraPresented) {
            CameraImagePicker { image in
                onImageSelected(image)
            }
            .ignoresSafeArea()
        }
        .photosPicker(isPresented: $isLibraryPresented, selection: $photoPickerItem, matching: .images)
        .onChange(of: photoPickerItem) { _, newItem in
            guard let newItem else { return }
            loadImage(from: newItem)
        }
    }

    private var preview: some View {
        let cardShape = RoundedRectangle(cornerRadius: .jsRadiusLG, style: .continuous)

        return ZStack {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .accessibilityLabel("선택한 사진 미리보기")
            } else {
                VStack(spacing: .jsXS) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.jsDisplayMedium)
                        .foregroundColor(.labelAlternative)
                        .accessibilityHidden(true)

                    Text(emptyTitle)
                        .font(.jsBodyMedium)
                        .foregroundColor(.labelStrong)

                    Text(emptySubtitle)
                        .font(.jsLabelMedium)
                        .foregroundColor(.labelAlternative)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.backgroundStrong)
            }
        }
        .frame(maxWidth: .infinity, minHeight: height, maxHeight: height)
        .clipShape(cardShape)
        .overlay {
            cardShape
                .stroke(
                    image == nil ? Color.primaryNormal.opacity(0.35) : Color.labelDisable.opacity(0.24),
                    style: StrokeStyle(
                        lineWidth: 1,
                        dash: image == nil ? [8, 6] : []
                    )
                )
        }
        .overlay(alignment: .topTrailing) {
            if image != nil {
                HStack(spacing: .jsMicro) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.positive)
                        .accessibilityHidden(true)

                    Text(selectedBadgeTitle)
                        .font(.jsLabelMedium)
                        .foregroundColor(.labelStrong)
                }
                .padding(.horizontal, .jsXS)
                .padding(.vertical, .jsMicro)
                .background(Color.backgroundNormal.opacity(0.92))
                .clipShape(Capsule())
                .padding(.jsSM)
            }
        }
    }

    private var cameraButton: some View {
        Button(action: presentCamera) {
            ImageAttachmentActionLabel(systemName: "camera.fill", title: cameraButtonTitle)
        }
        .buttonStyle(.plain)
        .jsTouchTarget()
        .accessibilityLabel(cameraButtonTitle)
        .accessibilityHint("카메라를 열어 사진을 촬영합니다")
    }

    private var libraryButton: some View {
        Button(action: presentLibrary) {
            ImageAttachmentActionLabel(systemName: "photo.on.rectangle", title: libraryButtonTitle)
        }
        .buttonStyle(.plain)
        .jsTouchTarget()
        .accessibilityLabel(libraryButtonTitle)
        .accessibilityHint("앨범에서 사진을 선택합니다")
    }

    private func presentCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            showFeedback(
                "이 기기에서는 카메라를 사용할 수 없어요. 앨범에서 사진을 선택해 주세요.",
                showsSettingsAction: false
            )
            return
        }

        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            clearFeedback()
            isCameraPresented = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        clearFeedback()
                        isCameraPresented = true
                    } else {
                        showFeedback(
                            "카메라 권한이 꺼져 있어요. iOS 설정에서 카메라 접근을 허용하거나 앨범에서 사진을 선택해 주세요.",
                            showsSettingsAction: true
                        )
                    }
                }
            }
        case .denied, .restricted:
            showFeedback(
                "카메라 권한이 꺼져 있어요. iOS 설정에서 카메라 접근을 허용하거나 앨범에서 사진을 선택해 주세요.",
                showsSettingsAction: true
            )
        @unknown default:
            showFeedback(
                "카메라를 열 수 없어요. 앨범에서 사진을 선택해 주세요.",
                showsSettingsAction: false
            )
        }
    }

    private func presentLibrary() {
        switch PHPhotoLibrary.authorizationStatus(for: .readWrite) {
        case .authorized, .limited, .notDetermined:
            clearFeedback()
            isLibraryPresented = true
        case .denied, .restricted:
            showFeedback(
                "앨범 접근 권한이 꺼져 있어요. iOS 설정에서 사진 접근을 허용하거나 카메라로 촬영해 주세요.",
                showsSettingsAction: true
            )
        @unknown default:
            showFeedback(
                "앨범을 열 수 없어요. 카메라로 사진을 촬영해 주세요.",
                showsSettingsAction: false
            )
        }
    }

    private func loadImage(from item: PhotosPickerItem) {
        Task {
            guard let data = try? await item.loadTransferable(type: Data.self),
                  let image = UIImage(data: data) else {
                await MainActor.run {
                    photoPickerItem = nil
                }
                return
            }

            await MainActor.run {
                onImageSelected(image)
                photoPickerItem = nil
                clearFeedback()
            }
        }
    }

    private func showFeedback(_ message: String, showsSettingsAction: Bool) {
        feedbackMessage = message
        isSettingsActionVisible = showsSettingsAction
    }

    private func clearFeedback() {
        feedbackMessage = nil
        isSettingsActionVisible = false
    }

    private func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        UIApplication.shared.open(url)
    }
}

private struct ImageAttachmentActionLabel: View {
    let systemName: String
    let title: String

    var body: some View {
        HStack(spacing: .jsXS) {
            Image(systemName: systemName)
                .font(.jsHeadlineSmall)
                .foregroundColor(.primaryNormal)

            Text(title)
                .font(.jsButtonMedium)
                .foregroundColor(.labelStrong)
                .lineLimit(1)
                .minimumScaleFactor(0.82)
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 48.jsScaled(.touchTarget))
        .padding(.horizontal, .jsSM)
        .background(
            RoundedRectangle(cornerRadius: .jsRadiusMD, style: .continuous)
                .fill(Color.backgroundStrong)
        )
        .overlay(
            RoundedRectangle(cornerRadius: .jsRadiusMD, style: .continuous)
                .stroke(Color.labelDisable.opacity(0.24), lineWidth: 1)
        )
        .contentShape(Rectangle())
    }
}

private struct CameraImagePicker: UIViewControllerRepresentable {
    let onImageSelected: (UIImage) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.cameraCaptureMode = .photo
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onImageSelected: onImageSelected)
    }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        private let onImageSelected: (UIImage) -> Void

        init(onImageSelected: @escaping (UIImage) -> Void) {
            self.onImageSelected = onImageSelected
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            if let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
                onImageSelected(image)
            }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}
