import SwiftUI
import ComposableArchitecture
import DSKit
import Domain
import PhotosUI

public struct NewTaskView: View {
    @Bindable var store: StoreOf<NewTaskFeature>
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(store: StoreOf<NewTaskFeature>) {
        self.store = store
    }

    public var body: some View {
        RedesignScreenScaffold(
            title: "새 작심 만들기",
            subtitle: "짧고 명확한 목표로 시작해요",
            stickyFooter: {
                buttonSection
            }
        ) {
            if store.saveFailed {
                saveFailedBanner
            }

            titleSection
            stageSection

            if PresentationRedesignFlags.isSectionEnabled(.taskFormPhoto) {
                photoSection
            }

            if PresentationRedesignFlags.isSectionEnabled(.taskFormAlarm) {
                alarmSection
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private var titleSection: some View {
        RedesignSectionCard(
            title: "제목",
            subtitle: "나중에 변경할 수 없어요"
        ) {
            JSInputField(
                title: "",
                placeholder: "예: 매일 10분 독서",
                text: $store.title
            )
        }
    }

    private var stageSection: some View {
        RedesignSectionCard(
            title: "스테이지",
            subtitle: "이번 목표를 며칠 동안 이어갈까요?"
        ) {
            JSStageSelector(
                selectedStage: stageDayBinding,
                stages: [3, 7, 15, 30]
            ) { selected in
                if !reduceMotion {
                    withAnimation(.easeInOut(duration: JSAnimation.durationNormal)) {
                        store.stageType = stageType(for: selected)
                    }
                } else {
                    store.stageType = stageType(for: selected)
                }
            }

            Text("선택된 기간: \(store.stageType.durationDays)일")
                .font(.jsBodySmall)
                .foregroundColor(.labelAlternative)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }

    private var photoSection: some View {
        RedesignSectionCard(
            title: "대표 사진",
            subtitle: "하루 인증의 기준이 되는 사진을 골라요"
        ) {
            ZStack(alignment: .bottomTrailing) {
                if let image = store.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 220)
                        .clipped()
                        .cornerRadius(.jsRadiusMD)
                } else {
                    RoundedRectangle(cornerRadius: .jsRadiusMD)
                        .fill(Color.backgroundStrong)
                        .frame(height: 220)
                        .overlay(
                            VStack(spacing: .jsXS) {
                                Image(systemName: "photo")
                                    .font(.jsDisplayLarge)
                                    .foregroundColor(.labelAlternative)
                                Text("대표 사진 추가")
                                    .font(.jsBodyMedium)
                                    .foregroundColor(.labelAlternative)
                            }
                        )
                }

                PhotosPicker(
                    selection: $store.photoPickerItem,
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
                .onChange(of: store.photoPickerItem) { _, newItem in
                    store.send(.photoPickerItemChanged(newItem))
                }
            }
        }
    }

    private var alarmSection: some View {
        RedesignSectionCard(
            title: "알림",
            subtitle: "매일 같은 시간에 인증 리마인드를 받을 수 있어요"
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
            }
        }
    }

    private var buttonSection: some View {
        VStack(spacing: .jsSM) {
            ZStack {
                JSButton(
                    title: "챌린지 시작",
                    style: .primary,
                    size: .large,
                    isEnabled: isFormValid && !store.isSaving
                ) {
                    store.send(.saveButtonTapped)
                }

                if store.isSaving {
                    JSProgressIndicator(size: .small, tintColor: .white)
                }
            }

            JSButton(
                title: "취소",
                style: .secondary,
                size: .large,
                isEnabled: !store.isSaving
            ) {
                store.send(.cancelButtonTapped)
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

    private var saveFailedBanner: some View {
        RedesignInlineErrorView(
            model: InlineErrorModel(
                message: "저장에 실패했어요. 네트워크 상태를 확인해 주세요."
            )
        )
    }

    private var isFormValid: Bool {
        !store.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && store.image != nil
    }

    private var stageDayBinding: Binding<Int> {
        Binding(
            get: { store.stageType.durationDays },
            set: { day in
                store.stageType = stageType(for: day)
            }
        )
    }

    private func stageType(for day: Int) -> StageType {
        switch day {
        case 3:
            return .three
        case 7:
            return .seven
        case 15:
            return .fifteen
        case 30:
            return .thirty
        default:
            return .three
        }
    }
}
