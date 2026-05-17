import SwiftUI
import DSKit
import Domain
import _Concurrency

public struct NewTaskView: View {
    @Bindable var model: NewTaskModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @FocusState private var focusedField: Field?
    @State private var toastPresented = false

    private enum Field: Hashable {
        case title
    }

    private enum SectionID {
        static let title = "newTask.title"
    }

    private let suggestions = ["매일 30분 운동", "책 한 챕터", "물 1L 마시기", "감사 일기", "10분 명상"]

    public init(model: NewTaskModel) {
        self.model = model
    }

    public var body: some View {
        ZStack(alignment: .bottom) {
            LinearGradient.wallpaperMorning
                .ignoresSafeArea()
            Color.backgroundNormal.opacity(0.18)
                .ignoresSafeArea()

            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: .jsLG) {
                        header
                        titleSection
                            .id(SectionID.title)
                        suggestionSection
                        dateSection
                        stageSection
                        reminderSection
                        visibilitySection
                    }
                    .padding(.horizontal, .jsMD)
                    .padding(.top, .jsLG)
                    .padding(.bottom, 132.jsScaled())
                }
                .onChange(of: focusedField) { _, newValue in
                    guard newValue == .title else { return }
                    withAnimation(reduceMotion ? .none : .easeInOut(duration: 0.24)) {
                        proxy.scrollTo(SectionID.title, anchor: .top)
                    }
                }
            }

            stickyCTA
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("취소") {
                    model.cancelButtonTapped()
                }
                .font(.jsButtonMedium)
                .foregroundColor(.labelAlternative)
                .disabled(model.isSaving)
                .jsTouchTarget()
                .accessibilityLabel("작심 만들기 취소")
                .accessibilityHint("작심 만들기를 닫습니다")
            }
        }
        .alert("작심 만들기를 그만둘까요?", isPresented: $model.isDiscardAlertPresented) {
            Button("계속 작성", role: .cancel) {}
            Button("그만두기", role: .destructive) {
                model.confirmDiscardDraft()
            }
        } message: {
            Text("입력한 내용은 저장되지 않아요.")
        }
        .onChange(of: model.toastMessage) { _, message in
            toastPresented = message != nil
        }
        .jsGlassToast(text: $model.toastMessage, isPresented: $toastPresented)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: .jsXS) {
            Text("새 작심 만들기")
                .font(.jsSerifDisplay)
                .foregroundColor(.labelStrong)

            Text("작게 시작하고, 매일 이어가요")
                .font(.jsSerifQuote)
                .foregroundColor(.labelAlternative)
        }
    }

    private var titleSection: some View {
        JSGlassCard(accessibilityLabel: "작심 제목 입력") {
            VStack(alignment: .leading, spacing: .jsMD) {
                Text("무엇을 이어갈까요?")
                    .font(.jsSerifTitle)
                    .foregroundColor(.labelStrong)

                JSInputField(
                    title: "",
                    placeholder: "예: 매일 10분 독서",
                    text: $model.title
                )
                .focused($focusedField, equals: .title)

                Text(model.trimmedTitle.isEmpty ? "작심 제목 미리보기" : model.trimmedTitle)
                    .font(.jsSerifTitle)
                    .foregroundColor(model.trimmedTitle.isEmpty ? .labelAssistive : .labelStrong)
                    .lineLimit(2)

                Text("\(model.title.count)/\(TextInputFieldPolicy.title.maxLength)")
                    .font(.jsMonoSmall)
                    .foregroundColor(.labelAssistive)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }

    private var suggestionSection: some View {
        VStack(alignment: .leading, spacing: .jsSM) {
            Text("추천")
                .font(.jsSerifTitle)
                .foregroundColor(.labelStrong)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: .jsXS) {
                    ForEach(suggestions, id: \.self) { suggestion in
                        Button {
                            model.suggestionTapped(suggestion)
                        } label: {
                            Text(suggestion)
                                .font(.jsBodySmall)
                                .foregroundColor(.labelStrong)
                                .padding(.horizontal, .jsMD)
                                .padding(.vertical, .jsXS)
                                .background(
                                    Capsule()
                                        .fill(Color.surfaceElevated.opacity(0.32))
                                )
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("\(suggestion) 추천 입력")
                    }
                }
                .padding(.vertical, .jsMicro)
            }
        }
    }

    private var dateSection: some View {
        JSGlassCard(accessibilityLabel: "작심 기간") {
            VStack(alignment: .leading, spacing: .jsMD) {
                Text("기간")
                    .font(.jsSerifTitle)
                    .foregroundColor(.labelStrong)

                DatePicker(
                    "시작일",
                    selection: Binding(
                        get: { model.startDate },
                        set: { model.startDateChanged($0) }
                    ),
                    displayedComponents: .date
                )
                .font(.jsBodyMedium)

                DatePicker(
                    "종료일",
                    selection: Binding(
                        get: { model.endDate },
                        set: { model.endDateChanged($0) }
                    ),
                    in: model.startDate...,
                    displayedComponents: .date
                )
                .font(.jsBodyMedium)
            }
        }
    }

    private var stageSection: some View {
        JSGlassCard(accessibilityLabel: "스테이지 선택") {
            VStack(alignment: .leading, spacing: .jsMD) {
                Text("스테이지")
                    .font(.jsSerifTitle)
                    .foregroundColor(.labelStrong)

                JSStageSelector(
                    selectedStage: stageDayBinding,
                    stages: [3, 7, 14, 21, 30, 45, 60, 90, 180]
                ) { selected in
                    model.stageTypeChanged(stageType(for: selected))
                }

                Text("\(model.stageType.durationDays)일 동안 이어갑니다")
                    .font(.jsMonoSmall)
                    .foregroundColor(.labelAlternative)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }

    private var reminderSection: some View {
        JSGlassCard(accessibilityLabel: "알림 설정") {
            VStack(alignment: .leading, spacing: .jsMD) {
                Toggle("알림 받기", isOn: $model.isAlarmEnabled)
                    .font(.jsBodyMedium)

                if model.isAlarmEnabled {
                    DatePicker(
                        "시간 선택",
                        selection: $model.alarmDate,
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(.wheel)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
        }
        .animation(reduceMotion ? .none : .easeInOut(duration: 0.24), value: model.isAlarmEnabled)
    }

    private var visibilitySection: some View {
        JSGlassCard(accessibilityLabel: "공개 범위") {
            VStack(alignment: .leading, spacing: .jsMD) {
                Text("공개 범위")
                    .font(.jsSerifTitle)
                    .foregroundColor(.labelStrong)

                VisibilityInlineRadioGroup(selection: $model.visibility)
            }
        }
    }

    private var stickyCTA: some View {
        VStack(spacing: .jsXS) {
            if model.saveFailed {
                Text("저장에 실패했어요. 잠시 후 다시 시도해 주세요.")
                    .font(.jsLabelMedium)
                    .foregroundColor(.destructive)
            }

            ZStack {
                JSButton(
                    title: "작심 시작하기",
                    style: .primary,
                    size: .large,
                    isEnabled: model.canSubmit && !model.isSaving
                ) {
                    model.saveButtonTapped()
                }

                if model.isSaving {
                    JSProgressIndicator(size: .small, tintColor: .backgroundNormal)
                }
            }
        }
        .padding(.horizontal, .jsMD)
        .padding(.top, .jsSM)
        .padding(.bottom, .jsMD)
        .background(Color.backgroundNormal.opacity(0.94))
    }

    private var stageDayBinding: Binding<Int> {
        Binding(
            get: { model.stageType.durationDays },
            set: { model.stageTypeChanged(stageType(for: $0)) }
        )
    }

    private func stageType(for day: Int) -> StageType {
        switch day {
        case 3:
            return .three
        case 7:
            return .seven
        case 14:
            return .fourteen
        case 21:
            return .twentyOne
        case 30:
            return .thirty
        case 45:
            return .fortyFive
        case 60:
            return .sixty
        case 90:
            return .ninety
        case 180:
            return .oneEighty
        default:
            return .three
        }
    }
}

private struct VisibilityInlineRadioGroup: View {
    @Binding var selection: TaskVisibility

    var body: some View {
        VStack(spacing: .jsXS) {
            ForEach(TaskVisibility.allCases, id: \.self) { visibility in
                Button {
                    selection = visibility
                } label: {
                    HStack(alignment: .top, spacing: .jsSM) {
                        Image(systemName: selection == visibility ? "checkmark.circle.fill" : "circle")
                            .font(.jsHeadlineMedium)
                            .foregroundColor(selection == visibility ? .forestAccent : .labelAlternative)

                        VStack(alignment: .leading, spacing: .jsMicro) {
                            Text(title(for: visibility))
                                .font(.jsBodyMedium)
                                .foregroundColor(.labelStrong)
                            Text(description(for: visibility))
                                .font(.jsLabelMedium)
                                .foregroundColor(.labelAlternative)
                        }

                        Spacer(minLength: .jsXS)
                    }
                    .padding(.jsSM)
                    .background(
                        RoundedRectangle(cornerRadius: .jsRadiusMD, style: .continuous)
                            .fill(selection == visibility ? Color.forestAccent.opacity(0.12) : Color.surfaceElevated.opacity(0.22))
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func title(for visibility: TaskVisibility) -> String {
        switch visibility {
        case .private:
            return "나만 보기"
        case .followers:
            return "팔로워 공개"
        case .public:
            return "전체 공개"
        }
    }

    private func description(for visibility: TaskVisibility) -> String {
        switch visibility {
        case .private:
            return "새 작심은 기본적으로 나만 볼 수 있어요."
        case .followers:
            return "서로 연결된 친구에게만 보여줍니다."
        case .public:
            return "공개 화면에서 누구나 볼 수 있습니다."
        }
    }
}
