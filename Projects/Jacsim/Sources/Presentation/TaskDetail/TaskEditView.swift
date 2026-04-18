import SwiftUI
import ComposableArchitecture
import DesignSystem
import PhotosUI
import _Concurrency

@MainActor
public struct TaskEditView: View {
    private enum ScrollTarget: Hashable {
        case titleSection
    }

    @Bindable var store: StoreOf<TaskEditFeature>
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @StateObject private var keyboardObserver = KeyboardObserver()
    @FocusState private var isTitleFieldFocused: Bool
    @State private var scrollTargetID: ScrollTarget?
    @State private var scrollRequestToken = 0
    @State private var scrollAnimation: Animation? = JSAnimation.navigation

    public init(store: StoreOf<TaskEditFeature>) {
        self.store = store
    }

    public var body: some View {
        RedesignScreenScaffold(
            title: "작심 수정",
            subtitle: "사진, 목표, 알림을 다시 정리해요",
            scrollToID: scrollTargetID,
            scrollAnchor: .center,
            scrollRequestToken: scrollRequestToken,
            scrollAnimation: scrollAnimation,
            stickyFooter: {
                TaskEditStickyFooter(
                    isSaving: store.isSaving,
                    isSaveEnabled: isSaveEnabled,
                    onCancel: { store.send(.cancelButtonTapped) },
                    onSave: { store.send(.saveButtonTapped) }
                )
            }
        ) {
            if store.saveFailed {
                RedesignInlineErrorView(
                    model: InlineErrorModel(
                        message: "저장에 실패했어요. 연결 상태를 확인한 뒤 다시 시도해 주세요."
                    )
                )
            }

            TaskEditPhotoSection(
                image: store.image,
                photoPickerItem: $store.photoPickerItem,
                onPhotoPickerItemChanged: { store.send(.photoPickerItemChanged($0)) }
            )
            basicInfoSection
            alarmSection
        }
        .navigationTitle("작심 수정")
        .navigationBarTitleDisplayMode(.inline)
        .interactiveDismissDisabled(store.hasUnsavedChanges || store.isSaving)
        .alert($store.scope(state: \.alert, action: \.alert))
        .onAppear { store.send(.onAppear) }
        .onChange(of: isTitleFieldFocused) { _, isFocused in
            if isFocused {
                requestScroll(to: .titleSection, duration: keyboardObserver.context.animationDuration)
            } else {
                clearInputScrollRequest()
            }
        }
        .onChange(of: keyboardObserver.context) { _, context in
            guard isTitleFieldFocused, context.isVisible else { return }
            requestScroll(to: .titleSection, duration: context.animationDuration)
        }
        .overlay(alignment: .bottom) {
            if let message = store.toastMessage {
                RedesignToastView(
                    message: message,
                    style: .error,
                    dismissAction: { store.send(.toastDismissed) }
                )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .task(id: message) {
                        try? await _Concurrency.Task.sleep(
                            nanoseconds: RedesignToastView.defaultDismissNanoseconds
                        )
                        store.send(.toastDismissed)
                    }
            }
        }
        .animation(reduceMotion ? .none : JSAnimation.toast, value: store.toastMessage)
        .animation(
            reduceMotion ? .none : .easeInOut(duration: keyboardObserver.context.animationDuration),
            value: keyboardObserver.context.isVisible
        )
    }

    private var basicInfoSection: some View {
        RedesignSectionCard(
            title: "기본 정보",
            subtitle: "수정할 제목을 입력해 주세요"
        ) {
            VStack(alignment: .trailing, spacing: .jsXS) {
                JSInputField(
                    title: "작심 제목",
                    placeholder: "예: 매일 10분 독서",
                    text: $store.title,
                    accessibilityLabel: "작심 제목",
                    focus: $isTitleFieldFocused
                )

                Text("\(store.title.count)/\(TextInputFieldPolicy.title.maxLength)")
                    .font(.jsLabelMedium)
                    .foregroundColor(.labelNeutral)

                Text("공백 포함 · 저장 시 앞뒤 공백은 자동 정리돼요")
                    .font(.jsLabelSmall)
                    .foregroundColor(.labelNeutral)
            }
        }
        .id(ScrollTarget.titleSection)
    }

    private var alarmSection: some View {
        RedesignSectionCard(
            title: "알림",
            subtitle: "선택한 시간에 오늘 포커스 작심 한 개를 리마인드해요"
        ) {
            Toggle("알림 받기", isOn: $store.isAlarmEnabled)
                .font(.jsBodyMedium)
                .accessibilityHint("매일 같은 시간에 작심 알림을 받도록 설정합니다")

            if store.isAlarmEnabled {
                DatePicker(
                    "리마인드 시간",
                    selection: $store.alarmDate,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.compact)
                .transition(.opacity.combined(with: .move(edge: .bottom)))
                .accessibilityHint("받고 싶은 알림 시간을 고릅니다")

                Text("권한이 허용되면 같은 날 중복 알림 대신 대표 작심 1건만 보내드려요")
                    .font(.jsLabelSmall)
                    .foregroundColor(.labelNeutral)
            }
        }
        .animation(reduceMotion ? .none : JSAnimation.navigation, value: store.isAlarmEnabled)
    }

    private var isSaveEnabled: Bool {
        !store.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func requestScroll(to target: ScrollTarget, duration: Double) {
        scrollTargetID = target
        scrollAnimation = reduceMotion ? nil : .easeInOut(duration: max(duration, 0.18))
        scrollRequestToken += 1
    }

    private func clearInputScrollRequest() {
        scrollTargetID = nil
    }
}

private struct TaskEditStickyFooter: View {
    let isSaving: Bool
    let isSaveEnabled: Bool
    let onCancel: () -> Void
    let onSave: () -> Void

    var body: some View {
        HStack(spacing: .jsSM) {
            JSButton(
                title: "취소",
                style: .secondary,
                size: .large,
                isEnabled: !isSaving
            ) {
                onCancel()
            }

            ZStack {
                JSButton(
                    title: "저장",
                    style: .primary,
                    size: .large,
                    isEnabled: isSaveEnabled && !isSaving
                ) {
                    onSave()
                }

                if isSaving {
                    JSProgressIndicator(size: .small, tintColor: .white)
                }
            }
        }
        .padding(.horizontal, .jsMD)
        .padding(.vertical, .jsMD)
        .background(
            LinearGradient(
                colors: [
                    Color.backgroundNormal.opacity(0),
                    Color.backgroundNormal,
                    Color.backgroundNormal
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
    }
}

@MainActor
private struct TaskEditPhotoSection: View {
    let image: UIImage?
    @Binding var photoPickerItem: PhotosPickerItem?
    let onPhotoPickerItemChanged: (PhotosPickerItem?) -> Void

    private let photoHeight: CGFloat = 232.jsScaled()
    private let cardShape = RoundedRectangle(cornerRadius: .jsRadiusLG, style: .continuous)

    var body: some View {
        RedesignSectionCard(
            title: "대표 사진",
            subtitle: "카드에 노출될 대표 이미지를 설정해요"
        ) {
            VStack(spacing: .jsSM) {
                photoPreview
                photoPicker
            }
        }
    }

    @ViewBuilder
    private var photoPreview: some View {
        ZStack {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                VStack(spacing: .jsXS) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.jsDisplayMedium)
                        .foregroundColor(.labelAlternative)

                    Text("대표 사진을 추가해 주세요")
                        .font(.jsBodyMedium)
                        .foregroundColor(.labelStrong)

                    Text("가로·세로 비율은 자동으로 맞춰져요")
                        .font(.jsLabelMedium)
                        .foregroundColor(.labelAlternative)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.backgroundStrong)
            }
        }
        .frame(maxWidth: .infinity, minHeight: photoHeight, maxHeight: photoHeight)
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

                    Text("선택됨")
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

    private var hasImage: Bool {
        image != nil
    }

    private var photoPicker: some View {
        PhotosPicker(selection: $photoPickerItem, matching: .images) {
            HStack(spacing: .jsXS) {
                Image(systemName: hasImage ? "arrow.triangle.2.circlepath" : "photo.badge.plus")
                    .font(.jsHeadlineSmall)
                    .foregroundColor(.primaryNormal)

                Text(hasImage ? "대표 사진 변경" : "대표 사진 선택")
                    .font(.jsButtonMedium)
                    .foregroundColor(.labelStrong)

                Spacer(minLength: .jsXS)

                Image(systemName: "chevron.right")
                    .font(.jsButtonSmall)
                    .foregroundColor(.labelAlternative)
            }
            .padding(.horizontal, .jsMD)
            .padding(.vertical, .jsSM)
            .background(
                RoundedRectangle(cornerRadius: .jsRadiusMD, style: .continuous)
                    .fill(Color.backgroundStrong)
            )
            .overlay(
                RoundedRectangle(cornerRadius: .jsRadiusMD, style: .continuous)
                    .stroke(Color.labelDisable.opacity(0.24), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(hasImage ? "대표 사진 변경" : "대표 사진 선택")
        .accessibilityHint("사진 보관함에서 새 대표 사진을 고릅니다")
        .onChange(of: photoPickerItem) { _, newItem in
            onPhotoPickerItemChanged(newItem)
        }
    }
}
