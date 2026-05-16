import Domain
import DSKit
import SwiftUI

public struct BragComposerView: View {
    @Bindable var model: BragComposerModel
    @Environment(\.dismiss) private var dismiss
    @State private var toastPresented = false

    public init(model: BragComposerModel) {
        self.model = model
    }

    public var body: some View {
        ZStack(alignment: .bottom) {
            LinearGradient.wallpaperDusk
                .ignoresSafeArea()
            Color.backgroundNormal.opacity(0.18)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: .jsLG) {
                    bodySection
                    taskSection
                    photoSection
                    visibilitySection
                }
                .padding(.horizontal, .jsMD)
                .padding(.top, .jsMD)
                .padding(.bottom, 120.jsScaled())
            }

            stickyCTA
        }
        .navigationTitle("자랑 글 쓰기")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("닫기") {
                    dismiss()
                }
                .font(.jsButtonMedium)
                .foregroundStyle(Color.labelAlternative)
            }
        }
        .onAppear { model.onAppear() }
        .onChange(of: model.toastMessage) { _, message in
            toastPresented = message != nil
        }
        .jsGlassToast(text: $model.toastMessage, isPresented: $toastPresented)
    }

    private var bodySection: some View {
        JSGlassCard(accessibilityLabel: "자랑 글 본문") {
            VStack(alignment: .leading, spacing: .jsMD) {
                Text("오늘 남길 한 문장")
                    .font(.jsSerifTitle)
                    .foregroundStyle(Color.labelStrong)

                JSInputField(
                    title: "",
                    placeholder: "완주 순간, 연속 기록, 오늘 인증을 적어보세요",
                    text: $model.body,
                    axis: .vertical,
                    lineLimit: 5
                )

                Text("추천 타입: \(typeTitle(model.suggestedType))")
                    .font(.jsMonoSmall)
                    .foregroundStyle(Color.labelAlternative)
            }
        }
    }

    private var taskSection: some View {
        VStack(alignment: .leading, spacing: .jsSM) {
            Text("작심 연결")
                .font(.jsSerifTitle)
                .foregroundStyle(Color.labelStrong)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: .jsXS) {
                    ForEach(model.tasks) { task in
                        Button {
                            model.taskSelected(task)
                        } label: {
                            Text(task.title)
                                .font(.jsBodySmall)
                                .foregroundStyle(model.selectedTaskID == task.id ? Color.backgroundNormal : Color.labelStrong)
                                .padding(.horizontal, .jsMD)
                                .padding(.vertical, .jsXS)
                                .background(
                                    Capsule()
                                        .fill(model.selectedTaskID == task.id ? Color.forestAccent : Color.surfaceElevated.opacity(0.34))
                                )
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("\(task.title) 작심 선택")
                    }
                }
                .padding(.vertical, .jsMicro)
            }
        }
    }

    private var photoSection: some View {
        JSGlassCard(accessibilityLabel: "사진 첨부") {
            VStack(alignment: .leading, spacing: .jsMD) {
                Text("사진")
                    .font(.jsSerifTitle)
                    .foregroundStyle(Color.labelStrong)

                JSPhotoPicker(
                    selectedImage: $model.selectedImage,
                    placeholderText: "사진 추가"
                ) { image in
                    model.imageSelected(image)
                }

                Button {
                    model.sampleImageTapped()
                } label: {
                    Label("샘플 사진 추가", systemImage: "photo.badge.plus")
                        .font(.jsBodySmall)
                }
                .buttonStyle(.glass)
                .accessibilityLabel("샘플 사진 추가")

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: .jsXS) {
                    ForEach(model.imagePaths, id: \.self) { path in
                        HStack(spacing: .jsXS) {
                            Text(path)
                                .font(.jsMonoSmall)
                                .foregroundStyle(Color.labelStrong)
                                .lineLimit(1)
                            Spacer()
                            Button {
                                model.removeImage(path)
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                            }
                            .accessibilityLabel("\(path) 삭제")
                        }
                        .padding(.jsXS)
                        .background(Color.surfaceElevated.opacity(0.3), in: RoundedRectangle(cornerRadius: .jsRadiusSM))
                    }
                }
            }
        }
    }

    private var visibilitySection: some View {
        JSGlassCard(accessibilityLabel: "공개 범위") {
            VStack(alignment: .leading, spacing: .jsMD) {
                Text("공개 범위")
                    .font(.jsSerifTitle)
                    .foregroundStyle(Color.labelStrong)

                ForEach(TaskVisibility.allCases, id: \.self) { visibility in
                    Button {
                        model.selectedVisibility = visibility
                    } label: {
                        HStack(spacing: .jsSM) {
                            Image(systemName: model.selectedVisibility == visibility ? "checkmark.circle.fill" : "circle")
                                .font(.jsHeadlineMedium)
                                .foregroundStyle(model.selectedVisibility == visibility ? Color.forestAccent : Color.labelAlternative)
                            VStack(alignment: .leading, spacing: .jsMicro) {
                                Text(visibilityTitle(visibility))
                                    .font(.jsBodyMedium)
                                    .foregroundStyle(Color.labelStrong)
                                Text(visibilityDescription(visibility))
                                    .font(.jsLabelMedium)
                                    .foregroundStyle(Color.labelAlternative)
                            }
                            Spacer(minLength: .jsXS)
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("\(visibilityTitle(visibility)) 공개 범위")
                }
            }
        }
    }

    private var stickyCTA: some View {
        ZStack {
            JSButton(
                title: "올리기",
                style: .primary,
                size: .large,
                isEnabled: model.canSubmit
            ) {
                model.submitTapped()
            }

            if model.isSaving {
                JSProgressIndicator(size: .small, tintColor: .backgroundNormal)
            }
        }
        .padding(.horizontal, .jsMD)
        .padding(.top, .jsSM)
        .padding(.bottom, .jsMD)
        .background(Color.backgroundNormal.opacity(0.94))
    }

    private func typeTitle(_ type: Domain.BragType) -> String {
        switch type {
        case .graduation:
            return "완주"
        case .streak:
            return "연속 기록"
        case .completion:
            return "오늘 완료"
        }
    }

    private func visibilityTitle(_ visibility: TaskVisibility) -> String {
        switch visibility {
        case .private:
            return "나만 보기"
        case .followers:
            return "친구 공개"
        case .public:
            return "전체 공개"
        }
    }

    private func visibilityDescription(_ visibility: TaskVisibility) -> String {
        switch visibility {
        case .private:
            return "내 기록으로만 보관합니다."
        case .followers:
            return "연결된 친구에게 공유합니다."
        case .public:
            return "추천 피드에도 노출될 수 있습니다."
        }
    }
}

#Preview {
    NavigationStack {
        BragComposerView(model: BragComposerModel(dependencies: .test))
    }
}
