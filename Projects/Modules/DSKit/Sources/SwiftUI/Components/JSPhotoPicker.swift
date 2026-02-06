import SwiftUI
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
    @State private var showPermissionDenied = false

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
                            .fill(Color.gray.opacity(0.2))
                            .overlay(
                                VStack(spacing: 12) {
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 32))
                                        .foregroundColor(.gray)

                                    Text(placeholderText)
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
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
                                    Button(action: {
                                        selectedImage = nil
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.system(size: 24))
                                            .foregroundColor(.white)
                                            .background(Color.black.opacity(0.5))
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

            if showPermissionDenied {
                VStack(alignment: .leading, spacing: 8) {
                    Text("사진 접근 권한이 필요해요.")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.gray)

                    Text("설정에서 사진 접근을 허용해주세요.")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)

                    Button("설정에서 허용하기") {
                        openSettings()
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .background(Color.gray.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
        .confirmationDialog("사진 선택", isPresented: $showActionSheet, titleVisibility: .visible) {
            Button("사진 라이브러리") {
                sourceType = .photoLibrary
                checkPhotoLibraryPermission()
            }

            Button("칩") {
                sourceType = .camera
                showImagePicker = true
            }

            if selectedImage != nil {
                Button("사진 삭제", role: .destructive) {
                    selectedImage = nil
                }
            }

            Button("취소", role: .cancel) {}
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(sourceType: sourceType, selectedImage: $selectedImage, onImageSelected: onImageSelected)
        }
    }

    private func checkPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized, .limited:
            showPermissionDenied = false
            showImagePicker = true
        case .denied, .restricted:
            showPermissionDenied = true
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { newStatus in
                DispatchQueue.main.async {
                    switch newStatus {
                    case .authorized, .limited:
                        showPermissionDenied = false
                        showImagePicker = true
                    case .denied, .restricted:
                        showPermissionDenied = true
                    case .notDetermined:
                        break
                    @unknown default:
                        showPermissionDenied = true
                    }
                }
            }
        @unknown default:
            showPermissionDenied = true
        }
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
                        .font(.system(size: 16))
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
