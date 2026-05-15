import SwiftUI
import ComposableArchitecture
import DSKit
import _Concurrency

public struct TaskEditView: View {
    @Bindable var store: StoreOf<TaskEditFeature>
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(store: StoreOf<TaskEditFeature>) {
        self.store = store
    }

    public var body: some View {
        RedesignScreenScaffold(
            title: "작심 수정",
            subtitle: "사진, 목표, 알림을 다시 정리해요",
            stickyFooter: {
                HStack(spacing: .jsSM) {
                    JSButton(title: "취소", style: .secondary, size: .large) {
                        store.send(.cancelButtonTapped)
                    }

                    JSButton(
                        title: "저장",
                        style: .primary,
                        size: .large,
                        isEnabled: isSaveEnabled
                    ) {
                        store.send(.saveButtonTapped)
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
        ) {
            if PresentationRedesignFlags.isSectionEnabled(.taskFormPhoto) {
                photoSection
            }

            basicInfoSection

            if PresentationRedesignFlags.isSectionEnabled(.taskFormAlarm) {
                alarmSection
            }
        }
        .navigationTitle("작심 수정")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { store.send(.onAppear) }
        .overlay(alignment: .bottom) {
            if let message = store.toastMessage {
                RedesignToastView(message: message, style: .error)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .task(id: message) {
                        try? await _Concurrency.Task.sleep(
                            nanoseconds: RedesignToastView.defaultDismissNanoseconds
                        )
                        store.send(.toastDismissed)
                    }
            }
        }
        .animation(reduceMotion ? .none : .easeInOut(duration: 0.25), value: store.toastMessage)
    }

    private var photoSection: some View {
        RedesignSectionCard(
            title: "대표 사진",
            subtitle: "카드에 노출될 대표 이미지를 설정해요"
        ) {
            ImageAttachmentPicker(
                image: store.image,
                emptyTitle: "대표 사진을 추가해 주세요",
                emptySubtitle: "가로·세로 비율은 자동으로 맞춰져요",
                height: 232.jsScaled()
            ) { image in
                store.send(.imageSelected(image))
            }
        }
    }

    private var basicInfoSection: some View {
        RedesignSectionCard(
            title: "기본 정보",
            subtitle: "수정할 제목을 입력해 주세요"
        ) {
            VStack(alignment: .trailing, spacing: .jsXS) {
                JSInputField(
                    title: "",
                    placeholder: "예: 매일 10분 독서",
                    text: $store.title
                )

                Text("\(store.title.count)/\(TextInputFieldPolicy.title.maxLength)")
                    .font(.jsLabelMedium)
                    .foregroundColor(.labelAssistive)

                Text("공백 포함 · 저장 시 앞뒤 공백은 자동 정리돼요")
                    .font(.jsLabelSmall)
                    .foregroundColor(.labelAssistive)
            }
        }
    }

    private var alarmSection: some View {
        RedesignSectionCard(
            title: "알림",
            subtitle: "매일 같은 시간에 리마인드를 받을 수 있어요"
        ) {
            Toggle("알림 받기", isOn: $store.isAlarmEnabled)
                .font(.jsBodyMedium)

            if store.isAlarmEnabled {
                DatePicker(
                    "시간 선택",
                    selection: $store.alarmDate,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.wheel)
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .animation(reduceMotion ? .none : .easeInOut(duration: 0.24), value: store.isAlarmEnabled)
    }

    private var isSaveEnabled: Bool {
        !store.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
