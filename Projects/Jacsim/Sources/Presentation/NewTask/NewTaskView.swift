import SwiftUI
import ComposableArchitecture
import DSKit
import Domain
import PhotosUI

public struct NewTaskView: View {
    @Bindable var store: StoreOf<NewTaskFeature>

    public init(store: StoreOf<NewTaskFeature>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    titleSection
                    stageSection
                    photoSection
                    alarmSection

                    if store.saveFailed {
                        saveFailedBanner
                    }

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }

            buttonSection
        }
        .background(Color.backgroundNormal)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("제목 입력")
                .font(.jsHeadlineSmall)
                .foregroundColor(.labelStrong)

            JSInputField(
                title: "",
                placeholder: "예: 매일 10분 독서",
                text: $store.title
            )

            Text("제목은 나중에 바꿀 수 없어요")
                .font(.jsLabelMedium)
                .foregroundColor(.labelAssistive)
        }
    }

    private var stageSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("스테이지 선택")
                .font(.jsHeadlineSmall)
                .foregroundColor(.labelStrong)

            Picker("스테이지", selection: $store.stageType) {
                Text("3일").tag(StageType.three)
                Text("7일").tag(StageType.seven)
                Text("15일").tag(StageType.fifteen)
                Text("30일").tag(StageType.thirty)
            }
            .pickerStyle(.segmented)
        }
    }

    private var photoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("대표 사진 선택")
                .font(.jsHeadlineSmall)
                .foregroundColor(.labelStrong)

            ZStack(alignment: .bottomTrailing) {
                if let image = store.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 220)
                        .clipped()
                        .cornerRadius(12)
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.backgroundStrong)
                        .frame(height: 220)
                        .overlay(
                            VStack(spacing: 8) {
                                Image(systemName: "photo")
                                    .font(.system(size: 36))
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
                        .font(.system(size: 40))
                        .foregroundColor(.primaryNormal)
                        .background(Color.white)
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
        VStack(alignment: .leading, spacing: 12) {
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
        .padding(.top, 8)
    }

    private var buttonSection: some View {
        VStack(spacing: 12) {
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
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
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
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundColor(.red)
                .font(.system(size: 14))
            Text("저장에 실패했어요. 다시 시도해주세요")
                .font(.jsBodySmall)
                .foregroundColor(.red)
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.red.opacity(0.1))
        .cornerRadius(8)
    }

    private var isFormValid: Bool {
        !store.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && store.image != nil
    }
}
