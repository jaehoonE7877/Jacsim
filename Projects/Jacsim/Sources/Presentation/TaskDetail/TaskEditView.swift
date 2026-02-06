import SwiftUI
import ComposableArchitecture
import DSKit
import PhotosUI
import _Concurrency

public struct TaskEditView: View {
    @Bindable var store: StoreOf<TaskEditFeature>
    @State private var photoPickerItem: PhotosPickerItem?
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
                RedesignSectionCard(
                    title: "대표 사진",
                    subtitle: "챌린지를 대표하는 이미지를 바꿀 수 있어요"
                ) {
                    ZStack(alignment: .bottomTrailing) {
                        if let image = store.image {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 220.jsScaled())
                                .clipped()
                                .cornerRadius(.jsRadiusMD)
                        } else {
                            Rectangle()
                                .fill(Color.labelDisable)
                                .frame(height: 220.jsScaled())
                                .cornerRadius(.jsRadiusMD)
                                .overlay(
                                    Image(systemName: "camera")
                                        .font(.jsDisplaySmall)
                                        .scaleEffect(1.6)
                                        .foregroundColor(.labelNeutral)
                                )
                        }

                        PhotosPicker(
                            selection: $photoPickerItem,
                            matching: .images
                        ) {
                            Image(systemName: "plus.circle.fill")
                                .font(.jsDisplayLarge)
                                .scaleEffect(1.3)
                                .foregroundColor(.primaryNormal)
                                .background(Color.backgroundNormal)
                                .clipShape(Circle())
                                .padding(.jsXS)
                        }
                        .onChange(of: photoPickerItem) { _, newItem in
                            guard let newItem else { return }
                            Task {
                                if let data = try? await newItem.loadTransferable(type: Data.self),
                                   let image = UIImage(data: data) {
                                    store.send(.imageSelected(image))
                                }
                            }
                        }
                    }
                }
            }

            RedesignSectionCard(title: "기본 정보") {
                VStack(alignment: .trailing, spacing: .jsXS) {
                    TextField("작심 이름", text: $store.title)
                        .font(.jsBodyMedium)
                        .padding()
                        .background(Color.backgroundNormal)
                        .cornerRadius(.jsRadiusMD)
                        .overlay(
                            RoundedRectangle(cornerRadius: .jsRadiusMD)
                                .stroke(Color.primaryNormal.opacity(0.5), lineWidth: 1)
                        )

                    Text("\(store.title.count)/\(TextInputFieldPolicy.title.maxLength)")
                        .font(.jsLabelMedium)
                        .foregroundColor(.labelAssistive)

                    Text("공백 포함 · 저장 시 앞뒤 공백은 자동 정리돼요")
                        .font(.jsLabelSmall)
                        .foregroundColor(.labelAssistive)
                }
            }

            RedesignSectionCard(title: "성공 목표") {
                Stepper("\(store.successTarget)회", value: $store.successTarget, in: 1...store.maxSuccessTarget)
                    .font(.jsBodyMedium)
            }

            if PresentationRedesignFlags.isSectionEnabled(.taskFormAlarm) {
                RedesignSectionCard(title: "알림") {
                    Toggle("알림 설정", isOn: $store.isAlarmEnabled)
                        .font(.jsBodyMedium)

                    if store.isAlarmEnabled {
                        DatePicker(
                            "알림 시간",
                            selection: $store.alarmDate,
                            displayedComponents: .hourAndMinute
                        )
                        .datePickerStyle(.wheel)
                    }
                }
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

    private var isSaveEnabled: Bool {
        !store.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
