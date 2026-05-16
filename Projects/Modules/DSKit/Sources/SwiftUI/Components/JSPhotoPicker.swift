import SwiftUI
import AVFoundation
import Photos
import PhotosUI
import UIKit

public struct JSPhotoPicker: View {
    @Binding var selectedImage: UIImage?
    let placeholderText: String
    let onImageSelected: ((UIImage) -> Void)?

    @State private var showImagePicker = false
    @State private var showActionSheet = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var feedbackMessage: String?
    @State private var showsSettingsAction = false

    public init(
        selectedImage: Binding<UIImage?>,
        placeholderText: String = "사진 추가",
        onImageSelected: ((UIImage) -> Void)? = nil
    ) {
        self._selectedImage = selectedImage
        self.placeholderText = placeholderText
        self.onImageSelected = onImageSelected
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: {
                showActionSheet = true
            }) {
                ZStack {
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                    } else {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.surfaceElevated.opacity(0.8))
                            .overlay(
                                VStack(spacing: 12) {
                                    Image(systemName: "camera.fill")
                                        .font(.largeTitle)
                                        .foregroundColor(Color.labelNeutral)

                                    Text(placeholderText)
                                        .font(.jsBody14Regular)
                                        .foregroundColor(Color.labelNeutral)
                                }
                            )
                    }
                }
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    Group {
                        if selectedImage != nil {
                            VStack {
                                HStack {
                                    Spacer()
                                    Button(action: removeSelectedImage) {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.title2)
                                            .foregroundColor(.white)
                                            .background(Color.surfaceOverlay.opacity(0.5))
                                            .clipShape(Circle())
                                    }
                                    .padding(12)
                                }
                                Spacer()
                            }
                        }
                    }
                )
            }
            .buttonStyle(PlainButtonStyle())
            .frame(minWidth: 44, minHeight: 44)
            .contentShape(Rectangle())

            if let feedbackMessage {
                VStack(alignment: .leading, spacing: 8) {
                    Text(feedbackMessage)
                        .font(.jsBody14Bold)
                        .foregroundColor(Color.labelNeutral)

                    if showsSettingsAction {
                        Button("설정에서 허용하기") {
                            openSettings()
                        }
                        .font(.jsLabel13Bold)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 10)
                        .background(Color.surfaceElevated.opacity(0.5))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
        }
        .confirmationDialog("사진 선택", isPresented: $showActionSheet, titleVisibility: .visible) {
            Button("사진 찍기") {
                presentCamera()
            }

            Button("앨범에서 선택") {
                presentPhotoLibrary()
            }

            if selectedImage != nil {
                Button("사진 삭제", role: .destructive) {
                    removeSelectedImage()
                }
            }

            Button("취소", role: .cancel) {}
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(
                sourceType: sourceType,
                selectedImage: $selectedImage
            ) { image in
                clearFeedback()
                onImageSelected?(image)
            }
                .presentationDragIndicator(.visible)
        }
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
            presentImagePicker(sourceType: .camera)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        presentImagePicker(sourceType: .camera)
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

    private func presentPhotoLibrary() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            showFeedback(
                "앨범을 열 수 없어요. 카메라로 사진을 촬영해 주세요.",
                showsSettingsAction: false
            )
            return
        }

        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        switch status {
        case .authorized, .limited:
            presentImagePicker(sourceType: .photoLibrary)
        case .denied, .restricted:
            showFeedback(
                "앨범 접근 권한이 꺼져 있어요. iOS 설정에서 사진 접근을 허용하거나 카메라로 촬영해 주세요.",
                showsSettingsAction: true
            )
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                DispatchQueue.main.async {
                    switch newStatus {
                    case .authorized, .limited:
                        presentImagePicker(sourceType: .photoLibrary)
                    case .denied, .restricted:
                        showFeedback(
                            "앨범 접근 권한이 꺼져 있어요. iOS 설정에서 사진 접근을 허용하거나 카메라로 촬영해 주세요.",
                            showsSettingsAction: true
                        )
                    case .notDetermined:
                        break
                    @unknown default:
                        showFeedback(
                            "앨범을 열 수 없어요. 카메라로 사진을 촬영해 주세요.",
                            showsSettingsAction: false
                        )
                    }
                }
            }
        @unknown default:
            showFeedback(
                "앨범을 열 수 없어요. 카메라로 사진을 촬영해 주세요.",
                showsSettingsAction: false
            )
        }
    }

    private func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        self.sourceType = sourceType
        clearFeedback()
        showImagePicker = true
    }

    private func removeSelectedImage() {
        selectedImage = nil
        clearFeedback()
    }

    private func showFeedback(_ message: String, showsSettingsAction: Bool) {
        feedbackMessage = message
        self.showsSettingsAction = showsSettingsAction
    }

    private func clearFeedback() {
        feedbackMessage = nil
        showsSettingsAction = false
    }

    private func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        UIApplication.shared.open(url)
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    let sourceType: UIImagePickerController.SourceType
    @Binding var selectedImage: UIImage?
    let onImageSelected: ((UIImage) -> Void)?

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
                parent.onImageSelected?(image)
            }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

struct JSPhotoPicker_Previews: PreviewProvider {
    struct PreviewContainer: View {
        @State private var image: UIImage?

        var body: some View {
            VStack(spacing: 20) {
                JSPhotoPicker(
                    selectedImage: $image,
                    placeholderText: "작심 대표 사진 추가"
                )

                if image != nil {
                    Text("Image selected")
                        .font(.jsBody16Regular)
                        .foregroundColor(.green)
                }
            }
            .padding()
        }
    }

    static var previews: some View {
        PreviewContainer()
    }
}
