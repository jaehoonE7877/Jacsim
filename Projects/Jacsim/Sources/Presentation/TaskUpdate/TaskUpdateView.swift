import SwiftUI
import ComposableArchitecture
import DesignSystem
import PhotosUI
import _Concurrency

public struct TaskUpdateView: View {
    private enum ScrollTarget: Hashable {
        case memoSection
    }

    @Bindable var store: StoreOf<TaskUpdateFeature>
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @StateObject private var keyboardObserver = KeyboardObserver()
    @FocusState private var isMemoFocused: Bool
    @State private var scrollTargetID: ScrollTarget?
    @State private var scrollRequestToken = 0
    @State private var scrollAnimation: Animation? = JSAnimation.navigation

    public init(store: StoreOf<TaskUpdateFeature>) {
        self.store = store
    }

    public var body: some View {
        RedesignScreenScaffold(
            title: "오늘 인증",
            subtitle: store.dateText,
            scrollToID: scrollTargetID,
            scrollAnchor: .bottom,
            scrollRequestToken: scrollRequestToken,
            scrollAnimation: scrollAnimation,
            stickyFooter: {
                bottomCTASection
            }
        ) {
            if store.isOverwriteMode {
                overwriteBanner
            }

            if store.saveFailed {
                errorMessage
            }

            photoPickerSection
            memoInputSection
        }
        .navigationTitle("오늘 인증")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(store.isSaving)
        .onAppear { store.send(.onAppear) }
        .onChange(of: isMemoFocused) { _, isFocused in
            if isFocused {
                requestScroll(to: .memoSection, duration: keyboardObserver.context.animationDuration)
            } else {
                clearInputScrollRequest()
            }
        }
        .onChange(of: keyboardObserver.context) { _, context in
            guard isMemoFocused, context.isVisible else { return }
            requestScroll(to: .memoSection, duration: context.animationDuration)
        }
        .overlay {
            if store.isSaving {
                loadingOverlay
            }
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
    
    private var overwriteBanner: some View {
        RedesignStateBanner(
            text: "다시 저장하면 오늘 기록이 최신 내용으로 덮어써져요",
            icon: "info.circle.fill",
            tintColor: .primaryNormal
        )
    }
    
    private var photoPickerSection: some View {
        let photoHeight: CGFloat = 300.jsScaled()
        let cardShape = RoundedRectangle(cornerRadius: .jsRadiusLG, style: .continuous)

        return RedesignSectionCard(
            title: "인증 사진",
            subtitle: "오늘 상태를 한 장으로 남겨요"
        ) {
            VStack(spacing: .jsSM) {
                ZStack {
                    if let image = store.image {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        VStack(spacing: .jsXS) {
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.jsDisplayMedium)
                                .foregroundColor(.labelNeutral)

                            Text("인증 사진을 추가해 주세요")
                                .font(.jsBodyMedium)
                                .foregroundColor(.labelStrong)

                            Text("비율은 자동으로 맞춰져요")
                                .font(.jsLabelMedium)
                                .foregroundColor(.labelNeutral)
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
                            store.image == nil ? Color.primaryNormal.opacity(0.35) : Color.labelDisable.opacity(0.24),
                            style: StrokeStyle(
                                lineWidth: 1,
                                dash: store.image == nil ? [8, 6] : []
                            )
                        )
                }
                .overlay(alignment: .topTrailing) {
                    if store.image != nil {
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

                let hasImage = store.image != nil
                PhotosPicker(selection: $store.photoPickerItem, matching: .images) {
                    HStack(spacing: .jsXS) {
                        Image(systemName: hasImage ? "arrow.triangle.2.circlepath" : "photo.badge.plus")
                            .font(.jsHeadlineSmall)
                            .foregroundColor(.primaryNormal)

                        Text(hasImage ? "인증 사진 변경" : "인증 사진 선택")
                            .font(.jsButtonMedium)
                            .foregroundColor(.labelStrong)

                        Spacer(minLength: .jsXS)

                        Image(systemName: "chevron.right")
                            .font(.jsButtonSmall)
                            .foregroundColor(.labelNeutral)
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
                .accessibilityLabel(hasImage ? "인증 사진 변경" : "인증 사진 선택")
                .accessibilityHint("사진 보관함에서 오늘 인증 사진을 고릅니다")
                .onChange(of: store.photoPickerItem) { _, newItem in
                    store.send(.photoPickerItemChanged(newItem))
                }
            }
        }
    }
    
    private var memoInputSection: some View {
        RedesignSectionCard(
            title: "한 줄 메모",
            subtitle: "선택 입력 · 최대 30자"
        ) {
            VStack(alignment: .leading, spacing: .jsXS) {
                TextField("짧게 남겨요 (선택)", text: $store.memo, axis: .vertical)
                    .font(.jsBodyMedium)
                    .focused($isMemoFocused)
                    .padding()
                    .background(Color.backgroundStrong)
                    .cornerRadius(.jsRadiusMD)
                    .overlay(
                        RoundedRectangle(cornerRadius: .jsRadiusMD)
                            .stroke(Color.primaryNormal.opacity(0.5), lineWidth: 1)
                    )
                    .lineLimit(2...4)
                    .accessibilityLabel("한 줄 메모")
                    .accessibilityHint("오늘 인증에 대한 짧은 메모를 남깁니다")
                
                HStack(alignment: .firstTextBaseline, spacing: .jsSM) {
                    Text("저장할 때 앞뒤 공백은 자동으로 정리돼요")
                        .font(.jsLabelSmall)
                        .foregroundColor(.labelNeutral)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text("\(store.memo.count)/\(TextInputFieldPolicy.memo.maxLength)")
                        .font(.jsLabelMedium)
                        .foregroundColor(.labelNeutral)
                        .monospacedDigit()
                }
            }
        }
        .id(ScrollTarget.memoSection)
    }
    
    private var errorMessage: some View {
        RedesignInlineErrorView(
            model: InlineErrorModel(
                message: "저장에 실패했어요. 다시 시도해 주세요."
            )
        )
    }
    
    private var bottomCTASection: some View {
        VStack(spacing: .jsSM) {
            if let footerBanner = footerBanner {
                RedesignStateBanner(
                    text: footerBanner.text,
                    icon: footerBanner.icon,
                    tintColor: footerBanner.tintColor
                )
                .padding(.horizontal, .jsMD)
                .accessibilityLabel(footerBanner.text)
            }

            JSButton(
                title: "오늘 인증 완료하기",
                style: .primary,
                size: .large,
                isEnabled: isButtonEnabled && !store.isSaving
            ) {
                store.send(.certifyButtonTapped)
            }
            .accessibilityHint(
                isButtonEnabled
                ? "오늘 인증을 저장합니다"
                : "인증 사진을 선택하면 활성화됩니다"
            )
            .padding(.horizontal, .jsMD)
            .padding(.vertical, .jsMD)
        }
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
    
    private var loadingOverlay: some View {
        ZStack {
            Color.backgroundStrong.opacity(0.6)
                .ignoresSafeArea()
            
            VStack(spacing: .jsSM) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .primaryNormal))
                    .scaleEffect(1.5)
                
                Text("저장 중...")
                    .font(.jsButtonSmall)
                    .foregroundColor(.labelStrong)
            }
            .padding(.jsXL)
            .background(.ultraThinMaterial)
            .cornerRadius(.jsRadiusLG)
        }
    }
    
    private var isButtonEnabled: Bool {
        store.image != nil
    }

    private var footerBanner: (text: String, icon: String, tintColor: Color)? {
        if let disabledReason = buttonDisabledReason {
            return (disabledReason, "info.circle.fill", .primaryNormal)
        }

        guard !store.isSaving, isButtonEnabled else { return nil }

        if store.isOverwriteMode {
            return ("저장하면 오늘 기록이 최신 사진과 메모로 바뀌어요.", "arrow.triangle.2.circlepath", .primaryNormal)
        }

        return ("좋아요. 저장하면 오늘 기록이 스테이지에 바로 반영돼요.", "sparkles", .positive)
    }

    private var buttonDisabledReason: String? {
        guard !store.isSaving, !isButtonEnabled else { return nil }
        return "인증 사진을 선택하면 바로 저장할 수 있어요."
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
